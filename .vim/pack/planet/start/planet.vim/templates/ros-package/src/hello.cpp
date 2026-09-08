#include <ros/ros.h>
int main(int argc, char **argv) { ros::init(argc, argv, "planet_hello"); ros::NodeHandle node; ROS_INFO("Hello from PlanetVim"); ros::spin(); }
