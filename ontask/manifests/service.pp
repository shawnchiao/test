# == Class: ontask::services
# Configures
class ontask::service inherits ontask {
  service {'rh-redis5-redis':
    ensure => running,
    enable => true,
  }
  service {'rh-nginx116-nginx':
    ensure => running,
    enable => true,
  }

  $ontask_svc_list = ['unisa-ontask','unisa-simple-queue','unisa-token-server']
  service {$ontask_svc_list:
    ensure => $ontask::www_ontask_service_ensure,
    enable => $ontask::www_ontask_service_enable
  }
}
