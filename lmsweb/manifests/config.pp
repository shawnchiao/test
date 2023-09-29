# -*- mode: ruby -*-
# vi: set ft=ruby :

class lmsweb::config inherits lmsweb
{

  if ($lmsweb::php_tideways_enabled) {
    $tideways_file_ensure = $lmsweb::file_ensure
  } else {
    $tideways_file_ensure = 'absent'
  }
  if ($lmsweb::php_opcache_enabled) {
    $opcache_file_ensure = $lmsweb::file_ensure
  } else {
    $opcache_file_ensure = 'absent'
  }
  if ($lmsweb::php_xdebug_enabled) {
    $xdebug_file_ensure = $lmsweb::file_ensure
  } else {
    $xdebug_file_ensure = 'absent'
  }

  # base nginx config
  file { "${lmsweb::nginx_config_path}/nginx.conf":
    ensure  => $lmsweb::file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/nginx.conf.erb'),
    notify  => Service[$lmsweb::nginx_svc_name],
  }



  #NGINX SSL Config
  if($lmsweb::nginx_ssl_enable)
  {
    file { "${lmsweb::nginx_config_path}/ssl":
      ensure => $lmsweb::dir_ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    }
    exec { 'exec_nginx_ssl_gen_cert':
      command => @("CMD"/Ls)
                 /bin/openssl req -new -newkey rsa:4096 -days ${lmsweb::nginx_ssl_cert_expiry}\
                 \s-nodes -x509 -subj "/C=AU/ST=South Australia/L=Adelaide/O=University of South Australia/OU=ISTS/CN=${::fqdn}"\
                 \s-keyout ${lmsweb::nginx_config_path}/ssl/${::fqdn}.key -out ${lmsweb::nginx_config_path}/ssl/${::fqdn}.cert
                 | CMD
                ,
      creates => "${lmsweb::nginx_config_path}/ssl/${::fqdn}.key",
      require => File["${lmsweb::nginx_config_path}/ssl"],
    }
    file { "${lmsweb::nginx_config_path}/ssl/${::fqdn}.key":
      ensure  => $lmsweb::file_ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      require => Exec[exec_nginx_ssl_gen_cert],
      }
    file { "${lmsweb::nginx_config_path}/ssl/${::fqdn}.cert":
      ensure  => $lmsweb::file_ensure,
      owner   => 'root',
      group   => 'root',
      mode    => '0655',
      require => Exec[exec_nginx_ssl_gen_cert],
    }
  }

  file { "${lmsweb::fpm_config_path}/php.d/50-redis.ini":
    ensure  => $lmsweb::file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/${lmsweb::php_version}/php-redis.ini.erb"),
  }

  file { "${lmsweb::fpm_config_path}/php.d/50-tideways.ini":
    ensure  => $tideways_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/${lmsweb::php_version}/php-tideways.ini.erb"),
    notify  => Service[$lmsweb::fpm_svc_name],
  }

  file { "${lmsweb::fpm_config_path}/php.d/10-opcache.ini":
    ensure  => $opcache_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/${lmsweb::php_version}/php-opcache.ini.erb"),
    notify  => Service[$lmsweb::fpm_svc_name],
  }

  file { "${lmsweb::fpm_config_path}/php.d/15-xdebug.ini":
    ensure  => $xdebug_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/${lmsweb::php_version}/php-xdebug.ini.erb"),
    notify  => Service[$lmsweb::fpm_svc_name],
  }

  file { "${lmsweb::fpm_config_path}/php.ini":
    ensure  => $lmsweb::file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/${lmsweb::php_version}/php.ini.erb"),
    notify  => Service[$lmsweb::fpm_svc_name],
  }

  file { "${lmsweb::fpm_config_path}/php-fpm.conf":
    ensure  => $lmsweb::file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("lmsweb/${lmsweb::php_version}/php-fpm.conf.erb"),
    notify  => Service[$lmsweb::fpm_svc_name],
  }

  # Add php binaries to environment PATH.
  file { '/etc/profile.d/php_path.sh':
    mode    => '0644',
    content => "PATH=\$PATH:${lmsweb::fpm_install_path}/usr/bin",
  }

  # Remove default fpm server config.
  file { "${lmsweb::fpm_config_path}/php-fpm.d/www.conf":
    ensure => absent,
  }

  file { "/etc/logrotate.d/${lmsweb::nginx_svc_name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-nginx.erb'),
    require => Package[$lmsweb::pkg_list],
  }

  file { "/etc/logrotate.d/${lmsweb::fpm_svc_name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-php-fpm.erb'),
    require => Package[$lmsweb::pkg_list],
  }

  file { '/etc/logrotate.d/newrelic-daemon':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-newrelic-daemon.erb'),
    require => Package[$lmsweb::pkg_list],
  }

  file { '/etc/logrotate.d/newrelic-php5':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-newrelic-php_agent.erb'),
    require => Package[$lmsweb::pkg_list],
  }

  file { '/etc/logrotate.d/newrelic-sysmond':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-newrelic-nrsysmond.erb'),
    require => Package[$lmsweb::pkg_list],
  }

  file { '/etc/logrotate.d/tideways-daemon':
    ensure  => $tideways_file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsweb/logrotate-tideways-daemon.erb'),
  }

  # Create freshclam systemd service and restart systemd.
  file { '/lib/systemd/system/clam-freshclam.service':
    mode    => '0444',
    owner   => 'root',
    group   => 'root',
    content => template('lmsweb/systemd-freshclam.erb'),
  }
  ~> exec { 'freshclam-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => [ '/usr/bin', '/bin', '/usr/sbin' ],
    refreshonly => true,
  }

  # Freshclam config.
  file { '/etc/freshclam.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('lmsweb/freshclam.conf.erb'),
    notify  => Service['clam-freshclam'],
  }

  # Set permissions on custom fpm_tmp_dir
  if($lmsweb::fpm_tmp_dir != '') {
    file { $lmsweb::fpm_tmp_dir:
      ensure => $lmsweb::dir_ensure,
      owner  => $lmsweb::www_user,
      group  => $lmsweb::www_group,
      mode   => '0755',
    }
  }
}
