<!doctype html>
<html <?php language_attributes(); ?>><head><meta charset="<?php bloginfo('charset'); ?>"><?php wp_head(); ?></head>
<body <?php body_class(); ?>><?php wp_body_open(); ?><main>
<?php while (have_posts()) : the_post(); ?><article><h1><?php the_title(); ?></h1><?php the_content(); ?></article><?php endwhile; ?>
<?php the_posts_navigation(); ?></main><?php wp_footer(); ?></body></html>
