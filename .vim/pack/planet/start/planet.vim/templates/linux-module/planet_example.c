#include <linux/module.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>
#include <linux/debugfs.h>
static unsigned int value = 1;
module_param(value, uint, 0644);
static struct dentry *debug_dir;
static struct proc_dir_entry *proc_entry;
static int show_value(struct seq_file *m, void *unused) { seq_printf(m, "%u\n", value); return 0; }
static int open_value(struct inode *inode, struct file *file) { return single_open(file, show_value, NULL); }
static const struct proc_ops ops = { .proc_open = open_value, .proc_read = seq_read, .proc_lseek = seq_lseek, .proc_release = single_release };
static int __init start(void) {
    proc_entry = proc_create("planet_example", 0444, NULL, &ops);
    if (!proc_entry) return -ENOMEM;
    debug_dir = debugfs_create_dir("planet_example", NULL);
    debugfs_create_u32("value", 0644, debug_dir, &value);
    return 0;
}
static void __exit stop(void) { debugfs_remove_recursive(debug_dir); proc_remove(proc_entry); }
module_init(start); module_exit(stop);
MODULE_LICENSE("Dual MIT/GPL");
MODULE_DESCRIPTION("Example module parameter, procfs and debugfs interface");
