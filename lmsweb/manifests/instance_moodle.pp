# == Resource lmsweb::instance_moodle
#  Create a moodle instance
define lmsweb::instance_moodle (

  # svc config
  $svc_name = undef,
  $www_name = undef,
  $www_port = undef,
  $root_dir = undef,
  $dirtarget = undef,
  $activedc = '',

  # data directory
  $data_mount_directory_name = undef,

  # Doc Services Printing
  $dsp_mount_ensure = $lmsweb::defaults::dsp_mount_ensure,
  $dsp_mount_dev = $lmsweb::defaults::dsp_mount_dev,
  $dsp_mount_opts = $lmsweb::defaults::dsp_mount_opts,
  $dsp_mount_type = $lmsweb::defaults::dsp_mount_type,

  # moodle util & cron
  $utilhostname = $lmsweb::defaults::utilhostname,
  $admincronenabled = $lmsweb::defaults::admincronenabled,
  $admincronminute = $lmsweb::defaults::admincronminute,
  $backupcronenabled = $lmsweb::defaults::backupcronenabled,
  $backupcronweekday = $lmsweb::defaults::backupcronweekday,
  $backupcronhour = $lmsweb::defaults::backupcronhour,
  $backupcronminute = $lmsweb::defaults::backupcronminute,
  $customphpcliopts = $lmsweb::defaults::customphpcliopts,
  $trashdircronenabled = $lmsweb::defaults::trashdircronenabled,
  $trashdircronhour = $lmsweb::defaults::trashdircronhour,
  $trashdircronminute = $lmsweb::defaults::trashdircronminute,
  $trashdirexpirydays = $lmsweb::defaults::trashdirexpirydays,
  $trashdirusleep = $lmsweb::defaults::trashdirusleep,

  # moodle app config
  $https = $lmsweb::defaults::https,
  $dbhost = $lmsweb::defaults::dbhost,
  $dbname = $lmsweb::defaults::dbname,
  $dbuser = $lmsweb::defaults::dbuser,
  $dbpass = $lmsweb::defaults::dbpass,
  $dbprefix = $lmsweb::defaults::dbprefix,
  $environment = $lmsweb::defaults::environment,
  $debugdisplay = $lmsweb::defaults::debugdisplay,
  $debug = $lmsweb::defaults::debug,
  $noemailever = $lmsweb::defaults::noemailever,
  $enableunittest = $lmsweb::defaults::enableunittest,
  $enablebehattest = $lmsweb::defaults::enablebehattest,
  $sslproxy = $lmsweb::defaults::sslproxy,
  $sessionhandler = $lmsweb::defaults::sessionhandler,
  $sessionredishost = $lmsweb::defaults::sessionredishost,
  $sessionredisport = $lmsweb::defaults::sessionredisport,
  $sessionredisdatabase = $lmsweb::defaults::sessionredisdatabase,
  $sessionredisacquiretimeout = $lmsweb::defaults::sessionredisacquiretimeout,
  $sessionredislockexpire = $lmsweb::defaults::sessionredislockexpire,
  $sessionredismaxlockswaiting = $lmsweb::defaults::sessionredismaxlockswaiting,
  $sessionredissentinelhosts = $lmsweb::defaults::sessionredissentinelhosts,
  $sessionredissentinelmastergroup = $lmsweb::defaults::sessionredissentinelmastergroup,
  $sentinelenablehostcache = $lmsweb::defaults::sentinelenablehostcache,
  $ssokey = $lmsweb::defaults::ssokey,
  $secretkey = $lmsweb::defaults::secretkey,
  $ssorequesttimeout = $lmsweb::defaults::ssorequesttimeout,
  $passwordsaltmain = $lmsweb::defaults::passwordsaltmain,
  $resultentryurl = $lmsweb::defaults::resultentryurl,
  $resultentrykey = $lmsweb::defaults::resultentrykey,
  $ssosecretkey = $lmsweb::defaults::ssosecretkey,
  $debugusers = $lmsweb::defaults::debugusers,
  $instancename = $lmsweb::defaults::instancename,
  $libssokey = $lmsweb::defaults::libssokey,
  $assignsecretkey = $lmsweb::defaults::assignsecretkey,
  $lrsssokey = $lmsweb::defaults::lrsssokey,
  $twofactorenckey = $lmsweb::defaults::twofactorenckey,
  $twofactorlocaltoken = $lmsweb::defaults::twofactorlocaltoken,
  $turnitintooltwoaccountid = $lmsweb::defaults::turnitintooltwoaccountid,
  $turnitintooltwosecretkey = $lmsweb::defaults::turnitintooltwosecretkey,
  $backupdestination = $lmsweb::defaults::backupdestination,
  $enablealtcompcache = $lmsweb::defaults::enablealtcompcache,

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
  if ($::hostname == $utilhostname) {
    if ($admincronenabled) {
      $admincronensure = 'present'
    } else {
      $admincronensure = 'absent'
    }
    if ($backupcronenabled) {
      $backupcronensure = 'present'
    } else {
      $backupcronensure = 'absent'
    }
    if ($trashdircronenabled) {
      $trashdircronensure = 'present'
    } else {
      $trashdircronensure = 'absent'
    }
  } else {
    $admincronensure = 'absent'
    $backupcronensure = 'absent'
    $trashdircronensure = 'absent'
  }
  if ($lmsweb::dsp_cifs_enable) {
    if ($dsp_mount_ensure == 'mounted') {
      file { "${instance_root}/dsp0":
        ensure => $lmsweb::dir_ensure,
        force  => $lmsweb::dir_force,
        owner  => $lmsweb::www_user,
        group  => $lmsweb::www_group,
        mode   => '0664',
      }
      -> mount { "${instance_root}/dsp0":
        ensure   => $dsp_mount_ensure,
        device   => $dsp_mount_dev,
        fstype   => $dsp_mount_type,
        options  => $dsp_mount_opts,
        remounts => false,
      }
    }
  } else {
    mount { "${instance_root}/dsp0":
        ensure   => 'absent',
      }
    -> file { "${instance_root}/dsp0":
        ensure => absent,
        force  => true
      }
  }

  # Application directories.
  file { ["${instance_root}/localcache", "${instance_root}/altcompcache"]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $lmsweb::www_user,
    group   => $lmsweb::www_group,
    mode    => '0664',
    require => File[$instance_root]
  }

  # Dirtarget typically only for local dev instances - hosted instances are provisioned by an external deployment process.
  if ($dirtarget) {
    file { $dirtarget:
      ensure => 'directory',
      owner  => $lmsweb::deployuser,
      group  => $lmsweb::deploygroup,
      mode   => '2755',
      before => File["${instance_root}/moodle"]
    }
    file { "${instance_root}/moodle":
      ensure  => 'link',
      force   => true, #$lmsweb::dir_force,
      target  => $dirtarget,
      owner   => $lmsweb::deployuser,
      group   => $lmsweb::deploygroup,
      mode    => '2755',
      require => File[$instance_root],
      before  => Exec["${instance_root}/moodle/config.php"]
    }
  }

  file { "${instance_root}/moodle-config.php":
    ensure  => 'file',
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0755',
    content => template('lmsweb/mdl-config.php.erb'),
  }

  # Create symlink to moodle-config.php (using exec instead of file ensure=>link in order so onlyif is available).
  # But how do we prevent update if content unchanged when using exec?
  exec { "${instance_root}/moodle/config.php":
    user    => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    path    => ['/usr/bin', '/bin'],
    command => "ln -snf ${instance_root}/moodle-config.php ${instance_root}/moodle/config.php",
    onlyif  => "test -e ${instance_root}/moodle",
    unless  => "test -e ${instance_root}/moodle/config.php",
    require => File["${instance_root}/moodle-config.php"],
  }

  # Define cron scripts - these will be present and enabled if:
  #  * cron task is explicitly enabled (e.g. admincronenabled = true)
  #  * current server matches server defined by $utilhostname
  #
  # Additionally the activedc script will also run before each execution and only allow crons to run
  # if the current DC is active (i.e. Moodle has not failed over to the standby DC)

  # Disable Cron Mailer by default
  Cron {
    environment => 'MAILTO=""'
  }

  if ($lmsweb::newrelic_api_key != '' and $lmsweb::newrelic_api_url != '' ) {
    if ($lmsweb::wwwproxyhost != '' and $lmsweb::wwwproxyport != '') {
      $curlproxy = "--proxy http://${lmsweb::wwwproxyhost}:${lmsweb::wwwproxyport}"
    } else {
      $curlproxy = ''
    }
    $cronmonitorheader1 = " -X POST -H \"Content-Type: application/json\""
    $cronmonitorheader2 = " -H \"X-Insert-Key:${lmsweb::newrelic_api_key}\""
    $cronmonitorheader3 = "  -H \"Content-Type: application/json\" ${lmsweb::newrelic_api_url}"
    $cronmonitorheader = "${cronmonitorheader1}${cronmonitorheader2}${cronmonitorheader3}"
    $cronmonitoradmin = " && curl ${curlproxy} -d '{\"eventType\":\"LTSCron\",\"name\":\"${name}-admin-cron\"}' ${cronmonitorheader} 2>&1"
    $cronmonitorbackup = " && curl ${curlproxy} -d '{\"eventType\":\"LTSCron\",\"name\":\"${name}-backup-cron\"}' ${cronmonitorheader} 2>&1"
  } else {
    $cronmonitoradmin = ''
    $cronmonitorbackup = ''
  }
  cron { "${name}-admin-cron":
    ensure  => $admincronensure,
    user    => $lmsweb::www_user,
    minute  => $admincronminute,
    command => @("CMD"/Ls)
               ${activedc} ${lmsweb::fpm_install_path}/usr/bin/php ${customphpcliopts} ${instance_root}/moodle/admin/cli/cron.php 2>&1 |\
               \s/usr/bin/logger -i -t ${name}-cron ${cronmonitoradmin}
               | CMD
              ,
  }
  cron { "${name}-backup-cron":
    ensure  => $backupcronensure,
    user    => $lmsweb::www_user,
    weekday => $backupcronweekday,
    hour    => $backupcronhour,
    minute  => $backupcronminute,
    command => @("CMD"/Ls)
               ${activedc} ${lmsweb::fpm_install_path}/usr/bin/php ${customphpcliopts}\
               ${instance_root}/moodle/admin/cli/automated_backups.php 2>&1 |\
               \s/usr/bin/logger -i -t ${name}-backup ${cronmonitorbackup}
               | CMD
              ,
  }
  cron { "${name}-trashdir-cron":
    ensure  => $trashdircronensure,
    user    => $lmsweb::www_user,
    hour    => $trashdircronhour,
    minute  => $trashdircronminute,
    command => @("CMD"/Ls)
               ${activedc} ${lmsweb::finddel_script_path} -p "${instance_root}/${data_mount_directory_name}/trashdir"\
               \s-u ${trashdirexpirydays} -s ${trashdirusleep} -e | /usr/bin/logger -i -t ${name}-trashdir-cron
               | CMD
              ,
  }

  file { "/etc/logrotate.d/mdl_${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-mdl.erb'),
  }
}
