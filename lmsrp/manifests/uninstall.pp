# == Class: lmsrp::install
# Removes previous version of nginx.
class lmsrp::uninstall inherits lmsrp
{
  if($lmsrp::nginx_remove_previous_version) {
    #remove packages
    package { $lmsrp::pkg_remove_list :
      ensure => 'purged',
    }
    -> file {[
      "/etc/opt/rh/${lmsrp::nginx_previous_version}",
      "/etc/logrotate.d/${lmsrp::nginx_previous_version}-nginx",
      "/etc/logrotate.d/${lmsrp::nginx_previous_version}-nginx.rpmsave"]:
      ensure  => 'absent',
      force   => true,
      recurse => true
    }
  }
}
