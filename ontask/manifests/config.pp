# == Class: ontask::config
# Configures nginx for ontask, and creates systemd unitfiles.
class ontask::config inherits ontask {

  file { "${ontask::nginx_config_path}/nginx.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/nginx.conf.erb')
  }

  file { "${ontask::nginx_config_path}/conf.d/":
    ensure  => 'directory',
    purge   => true,
    recurse => true
  }
  file { "${ontask::nginx_config_path}/conf.d/server_name.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/nginx_vhost.conf.erb')
  }

  file { "${ontask::systemd_unitfiles_path}/unisa-ontask.service":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/unisa-ontask.service.erb'),
    notify  => Exec['ontask_systemd_daemon_reload']
  }

  file { "${ontask::systemd_unitfiles_path}/unisa-simple-queue.service":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/unisa-simple-queue.service.erb'),
    notify  => Exec['ontask_systemd_daemon_reload']
  }

  file { "${ontask::systemd_unitfiles_path}/unisa-token-server.service":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/unisa-token-server.service.erb'),
    notify  => Exec['ontask_systemd_daemon_reload']
  }

  exec { 'ontask_systemd_daemon_reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    user        => 'root'
  }

  file { "${ontask::tnsnames_dir}/tnsnames.ora":
    ensure => 'file',
    source => 'puppet:///modules/ontask/tnsnames.ora',
    mode   => '0744',
    owner  => 'root',
    group  => 'root'
  }

  # Rsyslog  config
  file { '/etc/rsyslog.d/www-ontask.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/rsyslog-ontask.conf.erb'),
  }

  #Logrotate
  file { '/etc/logrotate.d/ontask':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/logrotate-ontask.erb'),
  }

  file { "/etc/logrotate.d/${ontask::nginx_version}-nginx":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/logrotate-nginx.erb'),
  }

}
