<?php
add_action('after_setup_theme', function () { add_theme_support('title-tag'); });
add_action('wp_enqueue_scripts', function () { wp_enqueue_style('planet-style', get_stylesheet_uri(), [], '0.1.0'); });
