# == Class: lmsrp::config
#
# Configure nginx reverse proxy.
#
# === Parameters
#  None
# === Variables
#
#  $file_ensure = $lmsrp::file_ensure
#  $nginx_svc_name = $lmsrp::nginx_svc_name
#  $pkg_list = $lmsrp::pkg_list
#  $rp_name  = $lmsrp::rp_name
#  $nginx_config_path = $lmsrp::nginx_config_path
#
# === Examples
#
#  class { 'lmsrp::config':
#  }
#
class lmsrp::config inherits lmsrp
{
  $file_ensure = $lmsrp::file_ensure
  $nginx_svc_name = $lmsrp::nginx_svc_name
  $pkg_list = $lmsrp::pkg_list
  $rp_name  = $lmsrp::rp_name
  $nginx_config_path = $lmsrp::nginx_config_path

  # base nginx config
  file { "${nginx_config_path}/nginx.conf":
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsrp/nginx.conf.erb'),
    notify  => Service[$nginx_svc_name],
  }

  file { "${nginx_config_path}/conf.d/rp.conf":
    ensure  => $file_ensure,
    content => template('lmsrp/rp.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service[$nginx_svc_name],
  }

  # Nginx logrotate - generic logs.
  file { "/etc/logrotate.d/${nginx_svc_name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsrp/logrotate-nginx.erb'),
    require => Package[$pkg_list],
  }

  # Nginx logrotate - Moodle RP Server Block.
  file { "/etc/logrotate.d/nginx_${rp_name}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('lmsrp/logrotate-nginx-mdl.erb'),
    require => Package[$pkg_list],
  }

  -> file { ["/etc/logrotate.d/${lmsrp::nginx_previous_svc_name}_${rp_name}","/etc/logrotate.d/${lmsrp::nginx_svc_name}_${rp_name}"]:
    ensure => 'absent'
  }

}
