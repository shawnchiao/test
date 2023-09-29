# == Class: lmsrp::service
#
# Setup nginx reverse proxy services.
#
# === Parameters
#  None
# === Variables
#
# $nginx_svc_name = $lmsrp::nginx_svc_name
# $svc_ensure = $lmsrp::svc_ensure
# $svc_enable = $lmsrp::svc_enable
#
# === Examples
#
#  class { 'lmsrp::service':
#  }
#
class lmsrp::service inherits lmsrp
{
  service { $lmsrp::nginx_previous_svc_name:
            ensure => 'stopped',
            enable => false,
            before => Service[$lmsrp::nginx_svc_name]
  }
  service { $lmsrp::nginx_svc_name :
            ensure  => $lmsrp::svc_ensure,
            enable  => $lmsrp::svc_enable,
            restart => "systemctl reload ${lmsrp::nginx_svc_name}"
          }
}
