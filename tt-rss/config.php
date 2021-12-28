<?php

foreach (glob('/etc/tt-rss/*.inc.php') as $filename) {
    include $filename;
}

if (true !== defined('NGINX_XACCEL_PREFIX')) {
    define('NGINX_XACCEL_PREFIX', '/tt-rss');
}
