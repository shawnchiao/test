# == Class lmsweb::service
#  Configures services
class lmsweb::service inherits lmsweb
{


  service { $lmsweb::fpm_svc_name:
    ensure  => $lmsweb::svc_ensure,
    enable  => $lmsweb::svc_enable,
    restart => "systemctl reload ${lmsweb::fpm_svc_name}",
  }

  service { $lmsweb::nginx_svc_name:
    ensure  => $lmsweb::svc_ensure,
    enable  => $lmsweb::svc_enable,
    restart => "systemctl reload ${lmsweb::nginx_svc_name}",
  }

  # Stop and disable previous versions.
  service { $lmsweb::nginx_previous_svc_name:
    ensure => 'stopped',
    enable => false,
    before => Service[$lmsweb::nginx_svc_name]
  }

  service { $lmsweb::fpm_previous_svc_name:
    ensure => 'stopped',
    enable => false,
    before => Service[$lmsweb::fpm_svc_name]
  }

  if ($lmsweb::newrelic_license_key != '') {
    # New Relic system monitor deprecated 01/05/2018.
    service { $lmsweb::newrelic_sysmond_svc_name:
      ensure => $lmsweb::newrelic_sysmond_svc_ensure,
      enable => false,
      # require => [ Exec['newrelic-sysmond-set-license'], File['/var/log/newrelic'] ]
    }
    service { $lmsweb::newrelic_infra_svc_name:
      ensure  => $lmsweb::newrelic_infra_svc_ensure,
      enable  => $lmsweb::svc_enable,
      require => [ Package[$lmsweb::newrelic_infra_package_list] ]
    }
  }

  service { 'clam-freshclam':
    ensure => $lmsweb::svc_ensure,
    enable => $lmsweb::svc_enable,
  }
}
