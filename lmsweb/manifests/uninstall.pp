# == Class lmsweb::uninstall
# Installs required packages for an nginx/php webserver
class lmsweb::uninstall inherits lmsweb
{
  if($lmsweb::php_remove_previous_version) {
    package {$lmsweb::remove_php_pkg_list:
      ensure => 'purged'
    }
    -> file { [
      "/etc/opt/remi/${lmsweb::php_previous_version}",
      "/etc/logrotate.d/${lmsweb::php_previous_version}-php-fpm",
      "/etc/logrotate.d/${lmsweb::php_previous_version}-php-fpm.rpmsave"
    ]:
      ensure  => 'absent',
      recurse => true,
      force   => true
    }
  }

  if($lmsweb::nginx_remove_previous_version) {
    package {$lmsweb::remove_nginx_pkg_list:
      ensure => 'purged'
    }
    -> file { [
      "/etc/opt/rh/${lmsweb::nginx_previous_version}",
      "/etc/logrotate.d/${lmsweb::nginx_previous_version}-nginx",
      "/etc/logrotate.d/${lmsweb::nginx_previous_version}-nginx.rpmsave"
    ]:
      ensure  => 'absent',
      recurse => true,
      force   => true
    }
  }
  if(!$lmsweb::dsp_cifs_enable) {
    if($lmsweb::dsp_cifs_utils_remove) {
      package { 'cifs-utils':
        ensure => 'purged'
      }
    }
  }
}
