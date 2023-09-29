# == Resource lmsweb::instance
#  Create an instance of a web application
define lmsweb::instance (

  # moodle source
  # $autoinstall = $lmsweb::defaults::autoinstall,
  # $autoupgrade = $lmsweb::defaults::autoupgrade,
  # $dirtarget = $lmsweb::defaults::dirtarget,

  # svc config
  $svc_name = undef, # default = $name
  $www_name = undef, # default = $svc_name > $name
  $www_port = $lmsweb::defaults::www_port,
  $root_dir = undef, # default = /$root_dir
  $fpm_enable_unix_socket = $lmsweb::defaults::fpm_enable_unix_socket,
  $fpm_tcp_port = $lmsweb::defaults::fpm_tcp_port,
  # define ngx_override_socket_path to specify an fpm instance managed outside of this puppet module (e.g. prev version)
  $ngx_override_socket_path = undef,
  $https = $lmsweb::defaults::https,
  # $apptype = '',

  # app instance config
  $mdl_instance = {},
  $mhr_instance = {},
  $lme_instance = {},

  # storage
  $data_mount_ensure = $lmsweb::defaults::data_mount_ensure,
  $data_mount_dev = $lmsweb::defaults::data_mount_dev,
  $data_mount_dev_ml = $lmsweb::defaults::data_mount_dev_ml,
  $data_mount_dev_cw = $lmsweb::defaults::data_mount_dev_cw,
  $data_mount_opts = $lmsweb::defaults::data_mount_opts,
  $data_mount_type = $lmsweb::defaults::data_mount_type,
  $data_mount_directory_name = $lmsweb::defaults::data_mount_directory_name,

  # log
  $log_mount_ensure = $lmsweb::defaults::log_mount_ensure,
  $log_mount_device = $lmsweb::defaults::log_mount_dev,
  $log_mount_opts = $lmsweb::defaults::log_mount_opts,
  $log_mount_type = $lmsweb::defaults::log_mount_type,
  $log_prefix_log_name = $lmsweb::defaults::log_prefix_log_name,
  $log_owner = $lmsweb::defaults::log_owner,
  $log_group = $lmsweb::defaults::log_group,
  $log_mode = $lmsweb::defaults::log_mode,

  # build
  $build_mount_ensure = $lmsweb::defaults::build_mount_ensure,
  $build_mount_device = $lmsweb::defaults::build_mount_dev,
  $build_mount_opts = $lmsweb::defaults::build_mount_opts,
  $build_mount_type = $lmsweb::defaults::build_mount_type,

  # cron
  $croncheckactivedc = $lmsweb::defaults::croncheckactivedc,

  # newrelic config
  $newrelic_appname = undef, # default = $name
  $newrelic_collector_ignore_exceptions = $lmsweb::defaults::newrelic_collector_ignore_exceptions,
  $newrelic_collector_ignore_errors = $lmsweb::defaults::newrelic_collector_ignore_errors,
  $newrelic_collector_ignore_user_exception_handler = $lmsweb::defaults::newrelic_collector_ignore_user_exception_handler,
  $newrelic_tracer_threshold = $lmsweb::defaults::newrelic_tracer_threshold,
  $newrelic_tracer_stack_trace_threshold = $lmsweb::defaults::newrelic_tracer_stack_trace_threshold,
  $newrelic_tracer_record_sql = $lmsweb::defaults::newrelic_tracer_record_sql,
  $newrelic_attributes_enabled = $lmsweb::defaults::newrelic_attributes_enabled,
  $newrelic_attributes_exclude = $lmsweb::defaults::newrelic_attributes_exclude,
  $newrelic_attributes_include = $lmsweb::defaults::newrelic_attributes_include,
  $newrelic_distributed_tracing_enabled = $lmsweb::defaults::newrelic_distributed_tracing_enabled,

  # error page config.
  $error_400_title = $lmsweb::defaults::error_400_title,
  $error_400_heading = $lmsweb::defaults::error_400_heading,
  $error_400_content = $lmsweb::defaults::error_400_content,
  $error_400_note = $lmsweb::defaults::error_400_note,
  $error_400_show_home_btn = $lmsweb::defaults::error_400_show_home_btn,
  $error_400_show_status_btn = $lmsweb::defaults::error_400_show_status_btn,
  $error_500_title = $lmsweb::defaults::error_500_title,
  $error_500_heading = $lmsweb::defaults::error_500_heading,
  $error_500_content = $lmsweb::defaults::error_500_content,
  $error_500_note = $lmsweb::defaults::error_500_note,
  $error_500_show_home_btn = $lmsweb::defaults::error_500_show_home_btn,
  $error_500_show_status_btn = $lmsweb::defaults::error_500_show_status_btn,
) {

  if (!empty($mdl_instance)) {
    $apptype = 'mdl'
  } elsif (!empty($mhr_instance)) {
    $apptype = 'mhr'
  } elsif (!empty($lme_instance)) {
    $apptype = 'lme'
  }

  $instance = init_instance_vars($name, $root_dir, $svc_name, $www_name, $https)
  $instance_root = $instance['instance_root']
  $instance_name = $instance['instance_name']
  $server_name = $instance['server_name']
  $wwwroot = $instance['wwwroot']

  # Application directories.
  file { [$instance_root]:
    ensure => $lmsweb::dir_ensure,
    force  => $lmsweb::dir_force,
    owner  => $lmsweb::deployuser,
    group  => $lmsweb::deploygroup,
    mode   => '0644',
  }

  #Setup site specific mount point
  if ($::unisadc == undef) {
    if ($data_mount_dev != undef) {
      $data_mount_device = $data_mount_dev
    }
  } else {
    if ($::unisadc == 'ml') {
      $data_mount_device = $data_mount_dev_ml
    } elsif ($::unisadc == 'cw') {
      $data_mount_device = $data_mount_dev_cw
    } else {
      fail("Unknown data centre value (${::unisadc}).")
    }
  }

  if ($fpm_enable_unix_socket) {
    $fpm_socket_path = "/run/php-fpm-${lmsweb::php_version}-${instance['instance_name']}.sock"
    if ($ngx_override_socket_path == undef) {
      $ngx_socket_path = $fpm_socket_path
    } else {
      $ngx_socket_path = $ngx_override_socket_path
    }
  }

  if ($croncheckactivedc) {
    $activedc = "activedc -q -u \"${instance['wwwroot']}\" &&"
  } else {
    $activedc = ''
  }

  # Data directory and mount.
  file { ["${instance_root}/${data_mount_directory_name}"]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $lmsweb::www_user,
    group   => $lmsweb::www_group,
    mode    => '0664',
    require => File[$instance_root]
  }
  if ($data_mount_device != '') {
    if ($data_mount_type == 'none') {
      file { [$data_mount_device]:
        ensure => $lmsweb::dir_ensure,
        force  => $lmsweb::dir_force,
        owner  => $lmsweb::www_user,
        group  => $lmsweb::www_group,
        mode   => '0775',
        before => Mount["${instance_root}/${data_mount_directory_name}"]

      }
    }
    mount { "${instance_root}/${data_mount_directory_name}":
      ensure   => $data_mount_ensure,
      device   => $data_mount_device,
      fstype   => $data_mount_type,
      options  => $data_mount_opts,
      remounts => false,
      require  => File["${instance_root}/${data_mount_directory_name}"]
    }
  }

  # Build directory and mount
  file { ["${instance_root}/build"]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0775',
    require => File[$instance_root]
  }

  if ($build_mount_device != '') {
    if ($build_mount_type == 'none') {
      file { [$build_mount_device]:
        ensure => $lmsweb::dir_ensure,
        force  => $lmsweb::dir_force,
        owner  => $lmsweb::deployuser,
        group  => $lmsweb::deploygroup,
        mode   => '0775',
        before => Mount["${instance_root}/build"]
      }
    }
    mount { "${instance_root}/build":
      ensure   => $build_mount_ensure,
      device   => $build_mount_device,
      fstype   => $build_mount_type,
      options  => $build_mount_opts,
      remounts => false,
      require  => File["${instance_root}/build"],
    }
  }

  # Log directory and mount
  $logsubdirs = [
    "${instance_root}/logs/nginx",
    "${instance_root}/logs/cron",
    "${instance_root}/logs/unisacli",
    "${instance_root}/logs/nginx/archive",
    "${instance_root}/logs/cron/archive",
    "${instance_root}/logs/unisacli/archive"]

  # PHP Logs require a different owner
  $phplogsubdirs = [ "${instance_root}/logs/php", "${instance_root}/logs/php/archive" ]



  if ($log_mount_device != '') {
    if ($log_mount_type == 'none') {
      file { [$log_mount_device]:
        ensure => $lmsweb::dir_ensure,
        force  => $lmsweb::dir_force,
        owner  => $log_owner,
        group  => $log_group,
        mode   => $log_mode,
        before => Mount["${instance_root}/logs"]
      }
    }
    mount { "${instance_root}/logs":
      ensure   => $log_mount_ensure,
      device   => $log_mount_device,
      fstype   => $log_mount_type,
      options  => $log_mount_opts,
      remounts => false,
      before   => File[$logsubdirs],
      require  => File["${instance_root}/logs"]
    }
  }
  # Create log subdirs after mounting logs (if mount specified)
  file { [$logsubdirs]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $log_owner,
    group   => $log_group,
    mode    => $log_mode,
    recurse => true,
    require => File["${instance_root}/logs"]
  }

  file { [$phplogsubdirs]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $lmsweb::www_user,
    group   => $lmsweb::www_group,
    mode    => $log_mode,
    recurse => true,
    require => File["${instance_root}/logs"]
  }

  file { [ "${instance_root}/logs" ]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $log_owner,
    group   => $log_group,
    mode    => $log_mode,
    require => File[$instance_root]
  }

  # Custom error directory and pages.
  file { ["${instance_root}/www_error"]:
    ensure  => $lmsweb::dir_ensure,
    force   => $lmsweb::dir_force,
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0644',
    require => File[$instance_root]
  }
  file { "${instance_root}/www_error/400.html":
    ensure  => $lmsweb::file_ensure,
    force   => $lmsweb::file_force,
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0644',
    content => template('lmsweb/www_error/400.html.erb'),
    require => File[$instance_root]
  }
  file { "${instance_root}/www_error/500.html":
    ensure  => $lmsweb::file_ensure,
    force   => $lmsweb::file_force,
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    mode    => '0644',
    content => template('lmsweb/www_error/500.html.erb'),
    require => File[$instance_root]
  }

  # Nginx server config.
  file { "${lmsweb::nginx_config_path}/conf.d/${name}.conf":
    ensure  => $lmsweb::file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/nginx-${apptype}.conf.erb"),
    notify  => Service[$lmsweb::nginx_svc_name],
  }

  # PHP-FPM server config.
  file { "${lmsweb::fpm_config_path}/php-fpm.d/${name}.conf":
    ensure  => $lmsweb::file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/fpm-www.conf.erb'),
    notify  => Service[$lmsweb::fpm_svc_name],
  }

  # Logrotate.
  file { "/etc/logrotate.d/nginx_${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-nginx-www.erb'),
  }

  -> file { [
    "/etc/logrotate.d/${lmsweb::nginx_previous_svc_name}_${name}",
    "/etc/logrotate.d/${lmsweb::nginx_svc_name}_${name}",
    ]:
    ensure => 'absent'
  }
  file { "/etc/logrotate.d/php_fpm_${name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-php-www.erb'),
  }
  file { [
    "/etc/logrotate.d/${lmsweb::fpm_previous_svc_name}_${name}",
    "/etc/logrotate.d/${lmsweb::fpm_svc_name}_${name}"
  ]:
    ensure => 'absent'
  }

  # Rsyslog  config (cron)
  file { "/etc/rsyslog.d/${name}-cron.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/rsyslog-cron.conf.erb'),
  }

  if($apptype == 'mdl') {
      # Rsyslog  config. (unisa cli)
      file { "/etc/rsyslog.d/${name}-unisacli.conf":
          ensure  => 'file',
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => template('lmsweb/rsyslog-unisacli.conf.erb'),
      }
  }

  exec { "lmwsweb_exec_syslog_restart_${name}" :
    command     => '/bin/systemctl restart rsyslog.service',
    subscribe   => File["/etc/rsyslog.d/${name}-cron.conf"],
    refreshonly => true
  }

  $instance_base = {
    svc_name => $svc_name,
    www_name => $www_name,
    root_dir => $root_dir,
    www_port => $www_port,
    data_mount_directory_name => $data_mount_directory_name,
    https => $https,
    activedc => $activedc,
  log_owner => $log_owner,
    log_group => $log_group,
    log_mode => $log_mode,
  }

  if (!empty($mdl_instance)) {
    $mdl_instance_hash = {"${name}" => merge($mdl_instance, $instance_base) }
    create_resources(lmsweb::instance_moodle, $mdl_instance_hash)
  } elsif (!empty($mhr_instance)) {
    $mhr_instance_hash = {"${name}" => merge($mhr_instance, $instance_base) }
    create_resources(lmsweb::instance_mahara, $mhr_instance_hash)
  } elsif (!empty($lme_instance)) {
    $lme_instance_hash = {"${name}" => merge($lme_instance, $instance_base) }
    create_resources(lmsweb::instance_lime, $lme_instance_hash)
  }
}
