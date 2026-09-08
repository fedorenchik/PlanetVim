#include <vulkan/vulkan.h>
#include <iostream>
int main() {
    VkApplicationInfo app{}; app.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    app.pApplicationName = "PlanetVim"; app.apiVersion = VK_API_VERSION_1_0;
    VkInstanceCreateInfo info{}; info.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO; info.pApplicationInfo = &app;
    VkInstance instance{};
    VkResult result = vkCreateInstance(&info, nullptr, &instance);
    if (result != VK_SUCCESS) { std::cerr << "vkCreateInstance failed: " << result << '\n'; return 1; }
    uint32_t count = 0; result = vkEnumeratePhysicalDevices(instance, &count, nullptr);
    std::cout << count << " Vulkan devices\n";
    vkDestroyInstance(instance, nullptr);
    return result == VK_SUCCESS ? 0 : 1;
}
