<?php

$vars = array(
    'PGA_DESC',
    'PGA_DESCS',
    'PGA_HOST',
    'PGA_HOSTS',
    'PGA_PORT',
    'PGA_PORTS',
    'PGA_SSLMODE',
    'PGA_DEFAULTDB',
    'PGA_DEFAULT_LANG',
    'PGA_AUTOCOMPLETE',
    'PGA_EXTRA_LOGIN_SECURITY',
    'PGA_OWNED_ONLY',
    'PGA_SHOW_ADVANCED',
    'PGA_SHOW_SYSTEM',
    'PGA_MIN_PASSWORD_LENGTH',
    'PGA_THEME',
    'PGA_SHOW_OIDS',
    'PGA_MAX_ROWS',
    'PGA_MAX_CHARS',
    'PGA_USE_XHTML_STRICT',
    'PGA_HELP_BASE',
    'PGA_AJAX_REFRESH',
    'PGA_PLUGINS'
);

foreach ($vars as $var) {
    $env = getenv($var);
    if (!isset($_ENV[$var]) && $env !== false) {
        $_ENV[$var] = $env;
    }
}

if (!empty($_ENV['PGA_HOSTS'])) {
    $descs = array_map('trim', explode(',', $_ENV['PGA_DESCS'] ?? 'PosgreSQL'));
    $hosts = array_map('trim', explode(',', $_ENV['PGA_HOSTS'] ?? ''));
    $ports = array_map('trim', explode(',', $_ENV['PGA_HOSTS'] ?? 5432));
} else {
    $descs = array($_ENV['PGA_DESC'] ?? 'PosgreSQL');
    $hosts = array($_ENV['PGA_HOST'] ?? '');
    $ports = array($_ENV['PGA_PORT'] ?? 5432);
}

/**
 * Central phpPgAdmin configuration.  As a user you may modify the
 * settings here for your particular configuration.
 */

for ($i = 0; isset($hosts[$i]); $i++) {

    // Display name for the server on the login screen
    $conf['servers'][$i]['desc'] = $descs[$i] ?? $descs[0];

    // Hostname or IP address for server.  Use '' for UNIX domain socket.
	// use 'localhost' for TCP/IP connection on this computer
    $conf['servers'][$i]['host'] = $hosts[$i] ?? $hosts[0];
    
    // Database port on server (5432 is the PostgreSQL default)
    $conf['servers'][$i]['port'] = $ports[$i] ?? $ports[0];
    
    // Database SSL mode
    // Possible options: disable, allow, prefer, require
    // To require SSL on older servers use option: legacy
    // To ignore the SSL mode, use option: unspecified
    $conf['servers'][$i]['sslmode'] = 'allow';
    if (isset($_ENV['PGA_SSLMODE'])) {
        $conf['servers'][$i]['sslmode'] = $_ENV['PGA_SSLMODE'];
    }

    // Change the default database only if you cannot connect to template1.
    // For a PostgreSQL 8.1+ server, you can set this to 'postgres'.
    $conf['servers'][$i]['defaultdb'] = 'template1';
    if (isset($_ENV['PGA_DEFAULTDB'])) {
        $conf['servers'][$i]['defaultdb'] = $_ENV['PGA_DEFAULTDB'];
    }

    // Specify the path to the database dump utilities for this server.
    // You can set these to '' if no dumper is available.
    $conf['servers'][0]['pg_dump_path'] = '/usr/bin/pg_dump';
    $conf['servers'][0]['pg_dumpall_path'] = '/usr/bin/pg_dumpall';
}

// Default language. E.g.: 'english', 'polish', etc.  See lang/ directory
// for all possibilities. If you specify 'auto' (the default) it will use
// your browser preference.
$conf['default_lang'] = 'auto';
if (isset($_ENV['PGA_DEFAULT_LANG'])) {
    $conf['default_lang'] = $_ENV['PGA_DEFAULT_LANG'];
}

// AutoComplete uses AJAX interaction to list foreign key values
// on insert fields. It currently only works on single column
// foreign keys. You can choose one of the following values:
// 'default on' enables AutoComplete and turns it on by default.
// 'default off' enables AutoComplete but turns it off by default.
// 'disable' disables AutoComplete.
$conf['autocomplete'] = 'default on';
if (isset($_ENV['PGA_AUTOCOMPLETE'])) {
    $conf['autocomplete'] = $_ENV['PGA_AUTOCOMPLETE'];
}

// If extra login security is true, then logins via phpPgAdmin with no
// password or certain usernames (pgsql, postgres, root, administrator)
// will be denied. Only set this false once you have read the FAQ and
// understand how to change PostgreSQL's pg_hba.conf to enable
// passworded local connections.
$conf['extra_login_security'] = true;
if (isset($_ENV['PGA_EXTRA_LOGIN_SECURITY'])) {
    $conf['extra_login_security'] = boolval($_ENV['PGA_EXTRA_LOGIN_SECURITY']);
}

// Only show owned databases?
// Note: This will simply hide other databases in the list - this does
// not in any way prevent your users from seeing other database by
// other means. (e.g. Run 'SELECT * FROM pg_database' in the SQL area.)
$conf['owned_only'] = false;
if (isset($_ENV['PGA_OWNED_ONLY'])) {
    $conf['owned_only'] = boolval($_ENV['PGA_OWNED_ONLY']);
}

// Display comments on objects?  Comments are a good way of documenting
// a database, but they do take up space in the interface.
$conf['show_comments'] = true;
if (isset($_ENV['PGA_SHOW_COMMENTS'])) {
    $conf['show_comments'] = boolval($_ENV['PGA_SHOW_COMMENTS']);
}

// Display "advanced" objects? Setting this to true will show
// aggregates, types, operators, operator classes, conversions,
// languages and casts in phpPgAdmin. These objects are rarely
// administered and can clutter the interface.
$conf['show_advanced'] = false;
if (isset($_ENV['PGA_SHOW_ADVANCED'])) {
    $conf['show_advanced'] = boolval($_ENV['PGA_SHOW_ADVANCED']);
}

// Display "system" objects?
$conf['show_system'] = false;
if (isset($_ENV['PGA_SHOW_SYSTEM'])) {
    $conf['show_system'] = boolval($_ENV['PGA_SHOW_SYSTEM']);
}

// Minimum length users can set their password to.
$conf['min_password_length'] = 1;
if (isset($_ENV['PGA_MIN_PASSWORD_LENGTH'])) {
    $conf['min_password_length'] = intval($_ENV['PGA_MIN_PASSWORD_LENGTH']);
}

// Width of the left frame in pixels (object browser)
$conf['left_width'] = 200;
if (isset($_ENV['PGA_LEFT_WIDTH'])) {
    $conf['left_width'] = intval($_ENV['PGA_LEFT_WIDTH']);
}

// Which look & feel theme to use
$conf['theme'] = 'default';
if (isset($_ENV['PGA_THEME'])) {
    $conf['theme'] = $_ENV['PGA_THEME'];
}

// Show OIDs when browsing tables?
// Only supported in versions <=11
$conf['show_oids'] = false;
if (isset($_ENV['PGA_SHOW_OIDS'])) {
    $conf['show_oids'] = boolval($_ENV['PGA_SHOW_OIDS']);
}

// Max rows to show on a page when browsing record sets
$conf['max_rows'] = 30;
if (isset($_ENV['PGA_MAX_ROWS'])) {
    $conf['max_rows'] = intval($_ENV['PGA_MAX_ROWS']);
}

// Max chars of each field to display by default in browse mode
$conf['max_chars'] = 50;
if (isset($_ENV['PGA_MAX_CHARS'])) {
    $conf['max_chars'] = intval($_ENV['PGA_MAX_CHARS']);
}

// Send XHTML strict headers?
$conf['use_xhtml_strict'] = false;
if (isset($_ENV['PGA_USE_XHTML_STRICT'])) {
    $conf['use_xhtml_strict'] = boolval($_ENV['PGA_USE_XHTML_STRICT']);
}

// Base URL for PostgreSQL documentation.
// '%s', if present, will be replaced with the PostgreSQL version
// (e.g. 8.4 )
$conf['help_base'] = 'http://www.postgresql.org/docs/%s/interactive/';
if (isset($_ENV['PGA_HELP_BASE'])) {
    $conf['help_base'] = $_ENV['PGA_HELP_BASE'];
}

// Configuration for ajax scripts
// Time in seconds. If set to 0, refreshing data using ajax will be disabled (locks and activity pages)
$conf['ajax_refresh'] = 3;
if (isset($_ENV['PGA_AJAX_REFRESH'])) {
    $conf['ajax_refresh'] = intval($_ENV['PGA_AJAX_REFRESH']);
}

/** Plugins management
 * Add plugin names to the following array to activate them
 * Example:
 *   $conf['plugins'] = array(
 *     'Example',
 *     'Slony'
 *   );
 */
$conf['plugins'] = array();
if (isset($_ENV['PGA_PLUGINS'])) {
    $conf['plugins'] = array_map('trim', explode(',', $_ENV['PGA_PLUGINS']));
}

/* Include User Defined Settings Hook */
if (file_exists('/etc/phppgadmin/config.user.inc.php')) {
    include('/etc/phppgadmin/config.user.inc.php');
}

/*****************************************
 * Don't modify anything below this line *
 *****************************************/

$conf['version'] = 19;
