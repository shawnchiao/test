# == resource lmsweb::instance_mahara
#  Creates an instance of limesurvey
define lmsweb::instance_lime (

  # svc config
  $svc_name = undef, # default = $name
  $www_name = undef, # default = $svc_name > $name
  $www_port = $lmsweb::defaults::www_port,
  $root_dir = undef, # default = /$root_dir
  $dirtarget = undef,
  $activedc = '',

  # data directory
  $data_mount_directory_name = $lmsweb::defaults::data_mount_directory_name,

  # app config
  $https = $lmsweb::defaults::https,
  $dbhost = $lmsweb::defaults::dbhost,
  $dbname = $lmsweb::defaults::dbname,
  $dbuser = $lmsweb::defaults::dbuser,
  $dbpass = $lmsweb::defaults::dbpass,
  $dbprefix = $lmsweb::defaults::dbprefix,
  $admincronenabled = true,
  $admincronminute = '*',
  $noemailever = $lmsweb::defaults::noemailever,
  $sessionhandle = $lmsweb::defaults::sessionhandle,
  # Logs
  $log_owner = $lmsweb::defaults::log_owner,
  $log_group = $lmsweb::defaults::log_group,
  $log_mode = $lmsweb::defaults::log_mode,

) {

  $instance = init_instance_vars($name, $root_dir, $svc_name, $www_name, $https)
  $instance_root = $instance['instance_root']
  $instance_name = $instance['instance_name']
  $server_name = $instance['server_name']
  $wwwroot = $instance['wwwroot']

  if($noemailever) {
    $sendmail = false
  } else {
    $sendmail = true
  }

  # Dirtarget typically only for local dev instances - hosted instances are provisioned by an external deployment process.
  if ($dirtarget) {
    file { "${instance_root}/lime":
      ensure  => 'link',
      force   => true, #$phpwap::dir_force,
      target  => $dirtarget,
      owner   => $lmsweb::deployuser,
      group   => $lmsweb::deploygroup,
      mode    => '2755',
      require => File[$instance_root],
      before  => Exec["${instance_root}/lime/application/config/config.php"]
    }
  }

  file { "${instance_root}/lime-config.php":
    ensure  => 'file',
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0755',
    content => template('lmsweb/lime-config.php.erb'),
  }

  # Create symlink to lime-config.php (using exec instead of file ensure=>link in order so onlyif is available).
  # But how do we prevent update if content unchanged when using exec?
  exec { "${instance_root}/lime/application/config/config.php":
    user    => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    path    => ['/usr/bin', '/bin'],
    command => "ln -snf ${instance_root}/lime-config.php ${instance_root}/lime/application/config/config.php",
    onlyif  => "test -e ${instance_root}/lime/application/config",
    unless  => "test -e ${instance_root}/lime/application/config/config.php",
    require => File["${instance_root}/lime-config.php"],
  }

}
