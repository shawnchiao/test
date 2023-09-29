# == Class lmsweb::install
# Installs required packages for an nginx/php webserver
class lmsweb::install inherits lmsweb
{

  if ($lmsweb::wwwproxyhost != '' and $lmsweb::wwwproxyport != '') {
    $proxyenv = [
      "http_proxy=http://${lmsweb::wwwproxyhost}:${lmsweb::wwwproxyport}",
      "https_proxy=http://${lmsweb::wwwproxyhost}:${lmsweb::wwwproxyport}"
    ]
  } else {
    $proxyenv = []
  }

  package { $lmsweb::pkg_list:
    ensure => $lmsweb::pkg_ensure,
  } -> file { '/etc/profile.d/scl-php.sh':
    content => "source scl_source enable ${lmsweb::php_version}",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
  -> exec { 'replace-usr-bin-php':
    unless  => "test -h /usr/bin/php && ls -l /usr/bin/php | grep -q ${lmsweb::php_version}",
    command => "ln -fs /opt/remi/${lmsweb::php_version}/root/usr/bin/php /usr/bin/php",
    path    => '/usr/bin/',
    user    => 'root',
    group   => 'root',
  }

  #Install cifs-utils and setup credential file
  # if enabled
  if ($lmsweb::dsp_cifs_enable) {
    package { 'cifs-utils':
      ensure => $lmsweb::pkg_ensure,
    }
    -> file { $lmsweb::dsp_cifs_cred_path:
      ensure  => file,
      content => template('lmsweb/dsp_cifs_cred.erb'),
      mode    => '0700',
      owner   => 'root',
      group   => 'root',
    }
  } else {
    file { $lmsweb::dsp_cifs_cred_path:
      ensure  => absent
    }
  }

  file { "${lmsweb::fpm_install_path}/usr/lib64/php/modules/tideways_xhprof.so":
    ensure => $lmsweb::tideways_ensure,
    #target => "/usr/lib/tideways/tideways-php-${php_major}.${php_minor}.so",
    source => "puppet:///modules/lmsweb/tideways/tideways_xhprof-php-${lmsweb::php_major}.${lmsweb::php_minor}.so",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    notify => Service[$lmsweb::fpm_svc_name],
  }

  user { $lmsweb::www_user:
    ensure     => present,
    uid        => 5005,
    shell      => '/sbin/nologin',
    managehome => true,
    gid        => 5005,
    require    => Group[$lmsweb::www_group],
  }

  group{ $lmsweb::www_group:
    ensure => present,
    gid    => 5005,
  }

  user { $lmsweb::deployuser:
    ensure     => present,
    uid        => 4995,
    shell      => '/bin/bash',
    managehome => true,
    gid        => 4995,
    require    => Group[$lmsweb::deploygroup, $lmsweb::www_group],
    groups     => [$lmsweb::www_group],
    membership => minimum,
  }

  group { $lmsweb::deploygroup:
    ensure => present,
    gid    => 4995,
  }

  file { "/home/${lmsweb::deployuser}/.bashrc":
    ensure  => 'file',
    source  => 'puppet:///modules/lmsweb/bash/bashrc',
    mode    => '0400',
    owner   => $lmsweb::deployuser,
    group   => $lmsweb::deploygroup,
    require => User[$lmsweb::deployuser],
  }

  file { "/home/${lmsweb::www_user}/.bashrc":
    ensure  => 'file',
    source  => 'puppet:///modules/lmsweb/bash/bashrc',
    mode    => '0400',
    owner   => $lmsweb::www_user,
    group   => $lmsweb::www_group,
    require => User[$lmsweb::www_user],
  }

  file { 'mdl-update-script':
    content => template('lmsweb/mdl-update.erb'),
    path    => $lmsweb::mdl_update_script_path,
    owner   => $lmsweb::www_user,
    group   => $lmsweb::www_group,
    # Only allow deployuser to execute deployment script.
    mode    => '0700',
    require => User[$lmsweb::deployuser]
  }

  file { 'activedc-script':
    source => 'puppet:///modules/lmsweb/activedc',
    path   => $lmsweb::activedc_script_path,
    mode   => '0755',
    owner  => 'root',
    group  => 'root'
  }

  file { 'finddel-script':
    source => 'puppet:///modules/lmsweb/finddel',
    path   => $lmsweb::finddel_script_path,
    mode   => '0755',
    owner  => 'root',
    group  => 'root'
  }

  file { ["/var${lmsweb::nginx_install_path}/lib/nginx",
          "/var${lmsweb::nginx_install_path}/log/nginx",
          "/var${lmsweb::nginx_install_path}/log/nginx/archive"]:
    ensure  => directory,
    recurse => true,
    owner   => $lmsweb::www_user,
    group   => $lmsweb::www_group,
    mode    => '0644',
    require => [User[$lmsweb::www_user], Package[$lmsweb::pkg_list]]
  }

  if ($lmsweb::newrelic_license_key != '') {

    package { $lmsweb::newrelic_agent_package_list:
      ensure => $lmsweb::newrelic_agent_package_ensure,
      notify => Service[$lmsweb::fpm_svc_name],
    }

    package { $lmsweb::newrelic_sysmond_package_list:
      ensure => $lmsweb::newrelic_sysmond_package_ensure,
      notify => Service[$lmsweb::newrelic_sysmond_svc_name],
    }

    # Reset the log directory, initially created by newrelic-install with root:root, to newrelic:newrelic.
    file { ['/var/log/newrelic', '/var/log/newrelic/archive']:
      ensure  => 'directory',
      group   => $lmsweb::www_group,
      mode    => '0664',
      recurse => true,
      require => [User[$lmsweb::www_user], Exec['newrelic-install']],
    }

    # Create placeholder so newrelc-install/unless doesn't fail on first install.
    file { "${lmsweb::fpm_config_path}/php.d/newrelic.ini":
      ensure  => file,
      replace => false,
      content => '.',
      mode    => '0644',
      before  => Exec['newrelic-install']
    }

    exec { 'newrelic-install':
      command => @("CMD"/Ls)
                 /usr/bin/newrelic-install purge &&\
                 \sNR_INSTALL_SILENT=yes NR_INSTALL_KEY=${lmsweb::newrelic_license_key} /usr/bin/newrelic-install install
                 | CMD
                ,
      path    => "/usr/bin:/bin:${lmsweb::fpm_install_path}/usr/bin",
      user    => 'root',
      group   => 'root',
      unless  => "/usr/bin/grep -qw '${lmsweb::newrelic_license_key}' ${lmsweb::fpm_config_path}/php.d/newrelic.ini",
      require => [ File["${lmsweb::fpm_config_path}/php.d/newrelic.ini"], Package['newrelic-php5'] ],
      notify  => Service[$lmsweb::fpm_svc_name],
    }

    # Set proxy in php agent config
    # TODO: update existing value - currently only works when setting is undefined.
    exec { 'newrelic-php-set-proxy':
      command => @("CMD"/Ls)
                 sed -i "s/.*newrelic.daemon.proxy.*/newrelic.daemon.proxy='${lmsweb::wwwproxyurl}'/"\
                 \s${lmsweb::fpm_config_path}/php.d/newrelic.ini
                 | CMD
                ,
      path    => '/usr/bin:/bin',
      user    => 'root',
      notify  => Service[$lmsweb::fpm_svc_name],
      unless  => "grep -qw '${lmsweb::wwwproxyurl}' ${lmsweb::fpm_config_path}/php.d/newrelic.ini",
      require => Exec[ 'newrelic-install' ],
    }

    package { $lmsweb::newrelic_infra_package_list:
      ensure => $lmsweb::newrelic_infra_package_ensure,
      notify => Service[$lmsweb::newrelic_infra_svc_name],
    }

    file { '/etc/newrelic-infra.yml':
      content => template('lmsweb/newrelic-infra.yml.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      notify  => Service[$lmsweb::newrelic_infra_svc_name],
    }

  }

  if ($lmsweb::nginx_enable_static_cache == true) {
    file { $lmsweb::nginx_static_cache_path:
      ensure => $lmsweb::dir_ensure,
      force  => $lmsweb::dir_force,
      owner  => $lmsweb::www_user,
      group  => $lmsweb::www_user,
      mode   => '0700',
    }

    mount { $lmsweb::nginx_static_cache_path:
      ensure  => $lmsweb::mnt_ensure,
      device  => tmpfs,
      fstype  => tmpfs,
      options => "size=${lmsweb::nginx_cache_size},uid=${lmsweb::www_user},gid=${lmsweb::www_group},mode=0700",
      require => File[$lmsweb::nginx_static_cache_path],
    }
  }

  file { '/usr/bin/cachetool.phar':
    ensure => 'file',
    source => "puppet:///modules/lmsweb/cachetool/cachetool-${lmsweb::cachetool_version}.phar",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

}
