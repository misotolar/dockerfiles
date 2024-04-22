<?php
$snippets = glob("/usr/local/tt-rss/conf.d/*.php");
foreach ($snippets as $snippet) {
	require_once $snippet;
}
