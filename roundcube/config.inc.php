<?php

$config['plugins'] = [];
$config['db_dsnw'] = getenv('ROUNDCUBEMAIL_DSNW');
$config['db_dsnr'] = getenv('ROUNDCUBEMAIL_DSNR');
$config['default_host'] = getenv('ROUNDCUBEMAIL_DEFAULT_HOST');
$config['default_port'] = getenv('ROUNDCUBEMAIL_DEFAULT_PORT');
$config['smtp_server'] = getenv('ROUNDCUBEMAIL_SMTP_SERVER');
$config['smtp_port'] = getenv('ROUNDCUBEMAIL_SMTP_PORT');
$config['temp_dir'] = getenv('ROUNDCUBEMAIL_TEMP_DIR');
$config['skin'] = getenv('ROUNDCUBEMAIL_SKIN');
$config['log_driver'] = 'stdout';
$config['plugins'] = array_filter(array_unique(array_merge($config['plugins'], [getenv('ROUNDCUBEMAIL_PLUGINS_PHP')])));
$config['zipdownload_selection'] = true;

foreach (glob('/etc/roundcube/*.php') as $filename) {
    include($filename);
}
