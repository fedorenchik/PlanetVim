#include <gtk/gtk.h>

typedef struct
{
	//TODO: add app widgets here
} app_widgets;

int main(int argc, char* argv[])
{
	GtkBuilder* builder;
	GtkWidget* window;
	app_widgets* widgets = g_slice_new(app_widgets);

	gtk_init(&argc, &argv);

	builder = gtk_builder_new_from_file("glade/window_main.glade");

	window = GTK_WIDGET(gtk_builder_get_object(builder, "window_main"));
	//TODO: assign widget pointers here
	gtk_builder_connect_signals(builder, widgets);

	g_object_unref(builder);

	gtk_widget_show_all(window);
	gtk_main();

	g_slice_free(app_widgets, widgets);
	return 0;
}

void on_window_main_destroy()
{
	gtk_main_quit();
}
