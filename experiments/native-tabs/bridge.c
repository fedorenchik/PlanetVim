#define _GNU_SOURCE
/* Experimental Linux/GTK3 bridge. See README.md before loading into GVim. */
#include <gtk/gtk.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>

static GtkWidget *book;
static GtkGesture *gesture;
static int listener = -1, client = -1;
static char socket_path[sizeof(((struct sockaddr_un *)0)->sun_path)];
static unsigned serial;

static void find_book(GtkWidget *widget, gpointer unused)
{
    (void)unused;
    if (book) return;
    if (GTK_IS_NOTEBOOK(widget)) { book = widget; return; }
    if (GTK_IS_CONTAINER(widget)) gtk_container_forall(GTK_CONTAINER(widget), find_book, NULL);
}

static int clicked_tab(double x, double y)
{
    int pages = gtk_notebook_get_n_pages(GTK_NOTEBOOK(book));
    for (int i = 0; i < pages; ++i) {
        GtkWidget *page = gtk_notebook_get_nth_page(GTK_NOTEBOOK(book), i);
        GtkWidget *label = gtk_notebook_get_tab_label(GTK_NOTEBOOK(book), page);
        int lx, ly;
        if (label && gtk_widget_get_mapped(label)
            && gtk_widget_translate_coordinates(label, book, 0, 0, &lx, &ly)
            && x >= lx && y >= ly
            && x < lx + gtk_widget_get_allocated_width(label)
            && y < ly + gtk_widget_get_allocated_height(label)) return i + 1;
    }
    return 0;
}

static void pressed(GtkGestureMultiPress *source, int n, double x, double y, gpointer unused)
{
    (void)n; (void)unused;
    if (!book || listener < 0) goto fallback;
    int target = clicked_tab(x, y);
    if (target == 0) goto fallback; /* Let Vim handle blank space and tab padding. */
    if (client < 0) client = accept4(listener, NULL, NULL, SOCK_NONBLOCK | SOCK_CLOEXEC);
    if (client < 0) goto fallback;
    /* Only numbers cross this channel. Never call Vim from a GTK callback. */
    char message[80];
    int size = snprintf(message, sizeof message, "%u %d %d\n", ++serial,
        target, gtk_notebook_get_n_pages(GTK_NOTEBOOK(book)));
    if (send(client, message, size, MSG_NOSIGNAL | MSG_DONTWAIT) == size) {
        gtk_gesture_set_state(GTK_GESTURE(source), GTK_EVENT_SEQUENCE_CLAIMED);
        return;
    }
    close(client);
    client = -1;
fallback:
    /* A recognized capture gesture otherwise stops legacy button handlers. */
    gtk_gesture_set_state(GTK_GESTURE(source), GTK_EVENT_SEQUENCE_DENIED);
}

int pv_tabs_stop(int unused)
{
    (void)unused;
    g_clear_object(&gesture);
    if (book) g_object_remove_weak_pointer(G_OBJECT(book), (gpointer *)&book);
    book = NULL;
    if (client >= 0) close(client);
    if (listener >= 0) close(listener);
    listener = client = -1;
    if (*socket_path) unlink(socket_path);
    *socket_path = 0;
    return 1;
}

int pv_tabs_start(const char *path)
{
    if (gesture) return -6;
    if (!path || !*path || strlen(path) >= sizeof socket_path) return -1;
    GList *windows = gtk_window_list_toplevels();
    for (GList *p = windows; p && !book; p = p->next)
        if (strcmp(gtk_widget_get_name(GTK_WIDGET(p->data)), "vim-main-window") == 0)
            find_book(GTK_WIDGET(p->data), NULL);
    g_list_free(windows);
    if (!book) return -2;
    g_object_add_weak_pointer(G_OBJECT(book), (gpointer *)&book);
    listener = socket(AF_UNIX, SOCK_STREAM | SOCK_NONBLOCK | SOCK_CLOEXEC, 0);
    if (listener < 0) { pv_tabs_stop(0); return -3; }
    struct sockaddr_un address = {.sun_family = AF_UNIX};
    strcpy(address.sun_path, path);
    if (bind(listener, (struct sockaddr *)&address, sizeof address) < 0) {
        pv_tabs_stop(0); return -4;
    }
    strcpy(socket_path, path);
    if (chmod(path, 0600) || listen(listener, 1)) { pv_tabs_stop(0); return -5; }
    gesture = gtk_gesture_multi_press_new(book);
    gtk_gesture_single_set_button(GTK_GESTURE_SINGLE(gesture), 3);
    /* Capture runs before Vim's ordinary notebook button-press handler. */
    gtk_event_controller_set_propagation_phase(GTK_EVENT_CONTROLLER(gesture), GTK_PHASE_CAPTURE);
    g_signal_connect(gesture, "pressed", G_CALLBACK(pressed), NULL);
    return 1;
}
