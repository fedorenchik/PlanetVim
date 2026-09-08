<?php
/**
 * Plugin Name: Planet Example
 * Description: Adds the [planet_hello] shortcode.
 * Version: 0.1.0
 * License: MIT
 */
if (!defined('ABSPATH')) { exit; }
add_shortcode('planet_hello', function () { return '<p>' . esc_html__('Hello from PlanetVim', 'planet-example') . '</p>'; });
