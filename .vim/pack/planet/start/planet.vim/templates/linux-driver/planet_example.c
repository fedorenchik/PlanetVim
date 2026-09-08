#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/of.h>
static int probe(struct platform_device *pdev) { dev_info(&pdev->dev, "Planet example bound\n"); return 0; }
static const struct of_device_id matches[] = { { .compatible = "planet,example" }, {} };
MODULE_DEVICE_TABLE(of, matches);
static struct platform_driver driver = { .probe = probe, .driver = { .name = "planet_example", .of_match_table = matches } };
module_platform_driver(driver);
MODULE_LICENSE("Dual MIT/GPL");
MODULE_DESCRIPTION("Minimal OF platform-driver starter");
