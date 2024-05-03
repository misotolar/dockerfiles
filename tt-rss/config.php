<?php
$snippets = glob("/usr/local/tt-rss/conf.d/*.php");
foreach ($snippets as $snippet) {
	require_once $snippet;
}

if (true !== defined('NGINX_ACCEL_PREFIX')) {
	define('NGINX_ACCEL_PREFIX', '/tt-rss');
}
