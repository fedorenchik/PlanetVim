#define _GNU_SOURCE
/* Linux GTK3 tab events only. All editor actions belong to Vim9script.
 * ABI 1; compile with -Wl,-z,nodelete because libcallnr closes its handle. */
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
static int pressed_tab;
static gboolean enabled;
static gint64 event_time;
#define TAB_ID "planetvim-tab-id"

int pv_tabs_abi(int unused) { (void)unused; return 1; }

int pv_tabs_enable(int value)
{
    enabled = value != 0;
    if (!enabled) pressed_tab = 0;
    return 1;
}

int pv_tabs_fresh(int sequence)
{
    return enabled && book && sequence > 0 && (unsigned)sequence == serial
        && g_get_monotonic_time() - event_time < 2000000;
}

/* Called from PlanetVim's tooltip expression, during Vim's actual GTK tab
 * redraw. Notebook page widgets move on drag and are reused on redraw: retag
 * each rendered page, not an independent index snapshot at TabEnter. */
int pv_tabs_tag(const char *value)
{
    int index, id;
    char extra;
    if (!book || !value || sscanf(value, "%d %d %c", &index, &id, &extra) != 2
        || index < 1 || id < 0) return 0;
    GtkWidget *page = gtk_notebook_get_nth_page(GTK_NOTEBOOK(book), index - 1);
    if (!page) return 0;
    g_object_set_data(G_OBJECT(page), TAB_ID, GINT_TO_POINTER(id));
    return 1;
}

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
            && y < ly + gtk_widget_get_allocated_height(label))
            return GPOINTER_TO_INT(g_object_get_data(G_OBJECT(page), TAB_ID));
    }
    return 0;
}

static void pressed(GtkGestureMultiPress *source, int n, double x, double y, gpointer unused)
{
    (void)n; (void)unused;
    pressed_tab = 0;
    if (!enabled || !book || listener < 0 || gtk_grab_get_current()) goto fallback;
    int target = clicked_tab(x, y);
    if (target == 0) goto fallback; /* Let Vim handle blank space and tab padding. */
    if (client < 0) client = accept4(listener, NULL, NULL, SOCK_NONBLOCK | SOCK_CLOEXEC);
    if (client < 0) goto fallback;
    pressed_tab = target;
    gtk_gesture_set_state(GTK_GESTURE(source), GTK_EVENT_SEQUENCE_CLAIMED);
    return;
fallback:
    /* A recognized capture gesture otherwise stops legacy button handlers. */
    gtk_gesture_set_state(GTK_GESTURE(source), GTK_EVENT_SEQUENCE_DENIED);
}

static void released(GtkGestureMultiPress *source, int n, double x, double y, gpointer unused)
{
    (void)source; (void)n; (void)x; (void)y; (void)unused;
    int target = pressed_tab;
    pressed_tab = 0;
    if (!target || !enabled || !book || client < 0) return;
    /* :popup! uses a synthetic button-0 event. Opening it before button 3 is
     * released makes GTK dismiss it on that release. Notify Vim only now,
     * retaining the tab identity captured on press, including after a drag. */
    /* Only numbers cross this channel. Never call Vim from a GTK callback. */
    char message[80];
    /* libcallnr takes an int; keep the serial in its positive range. */
    serial = serial >= G_MAXINT ? 1 : serial + 1;
    int size = snprintf(message, sizeof message, "%u %d\n", serial, target);
    if (send(client, message, size, MSG_NOSIGNAL | MSG_DONTWAIT) == size) {
        event_time = g_get_monotonic_time();
        return;
    }
    close(client);
    client = -1;
}

int pv_tabs_stop(int unused)
{
    (void)unused;
    enabled = FALSE;
    pressed_tab = 0;
    event_time = 0;
    g_clear_object(&gesture);
    if (book) {
        for (int i = 0; i < gtk_notebook_get_n_pages(GTK_NOTEBOOK(book)); ++i)
            g_object_set_data(G_OBJECT(gtk_notebook_get_nth_page(GTK_NOTEBOOK(book), i)), TAB_ID, NULL);
        g_object_remove_weak_pointer(G_OBJECT(book), (gpointer *)&book);
    }
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
    g_signal_connect(gesture, "released", G_CALLBACK(released), NULL);
    return 1;
}
