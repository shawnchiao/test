# == Resource lmsweb::instance_mahara
#  Creates an instance of mahara
define lmsweb::instance_mahara (

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
  $customphpcliopts = $lmsweb::defaults::customphpcliopts,
  $noemailever = $lmsweb::defaults::noemailever,
  $sslproxy = $lmsweb::defaults::sslproxy,
  $searchplugin = $lmsweb::defaults::searchplugin,
  $emailcontact = $lmsweb::defaults::emailcontact,
  $noreplyaddress = $lmsweb::defaults::noreplyaddress,
  $dblogerror = $lmsweb::defaults::dblogerror,
  $urlsecret = $lmsweb::defaults::urlsecret,
  $skins = $lmsweb::defaults::skins,
  $passwordsaltmain = $lmsweb::defaults::passwordsaltmain,
  $productionmode = $lmsweb::defaults::productionmode,
  $pathtoclam = $lmsweb::defaults::pathtoclam,
  $usersuniquebyusername = $lmsweb::defaults::usersuniquebyusername,

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

  # Check config to work out which crons should be enabled.
  if ($admincronenabled) {
    $admincronensure = 'present'
  } else {
    $admincronensure = 'absent'
  }

  if($noemailever) {
    $sendmail = false
  } else {
    $sendmail = true
  }

  # Dirtarget typically only for local dev instances - hosted instances are provisioned by an external deployment process.
  if ($dirtarget) {
    file { "${instance_root}/mahara":
      ensure  => 'link',
      force   => true, #$phpwap::dir_force,
      target  => $dirtarget,
      owner   => $lmsweb::deployuser,
      group   => $lmsweb::deploygroup,
      mode    => '2755',
      require => File[$instance_root],
      before  => Exec["${instance_root}/mahara/htdocs/config.php"]
    }
  }


  file { "${instance_root}/mahara-config.php":
    ensure  => 'file',
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0755',
    content => template('lmsweb/mahara-config.php.erb'),
  }

  # Create symlink to mahara-config.php (using exec instead of file ensure=>link in order so onlyif is available).
  # But how do we prevent update if content unchanged when using exec?
  exec { "${instance_root}/mahara/htdocs/config.php":
    user    => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    path    => ['/usr/bin', '/bin'],
    command => "ln -snf ${instance_root}/mahara-config.php ${instance_root}/mahara/htdocs/config.php",
    onlyif  => "test -e ${instance_root}/mahara",
    unless  => "test -e ${instance_root}/mahara/htdocs/config.php",
    require => File["${instance_root}/mahara-config.php"],
  }

  # Define cron scripts - these will be present and enabled if:
  #  * cron task is explicitly enabled (e.g. admincronenabled = true)
  #  * current server matches server defined by $utilhostname
  #
  # Additionally the activedc script will also run before each execution and only allow crons to run
  # if the current DC is active (i.e. Mahara has not failed over to the standby DC)

  # Disable Cron Mailer by default
  Cron {
    environment => 'MAILTO=""'
  }

  cron { "${name}-admin-cron":
    ensure  => $admincronensure,
    user    => $lmsweb::www_user,
    minute  => $admincronminute,
    command => @("CMD"/Ls)
               ${activedc} ${lmsweb::fpm_install_path}/usr/bin/php ${customphpcliopts} ${instance_root}/mahara/htdocs/lib/cron.php 2>&1 |\
               \s/usr/bin/logger -i -t ${name}-cron
               | CMD
              ,
  }

  file { "/etc/logrotate.d/mahara_${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-mdl.erb'),
  }
}
