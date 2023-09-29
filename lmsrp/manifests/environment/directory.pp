# == Class: lmsrp::environment::directory
#
# Setup required directory structure.
#
# === Parameters
#  None
# === Variables
#  None
# === Examples
#
#  class { 'lmsrp::environment::directory':
#  }
#
class lmsrp::environment::directory inherits lmsrp
  {
    file { [$lmsrp::rp_instance_path, "/var/log${lmsrp::rp_instance_path}", "/var/log/${lmsrp::rp_instance_path}/archive"]:
      ensure => $lmsrp::dir_ensure,
      mode   => '0755',
    }

    -> file { $lmsrp::rp_instance_log_path:
      ensure => 'link',
      target => "/var/log${lmsrp::rp_instance_path}",
    }

    file { $lmsrp::rp_instance_cache_path:
      ensure  => $lmsrp::dir_ensure,
      force   => $lmsrp::dir_force,
      owner   => nginx,
      group   => nginx,
      mode    => '0700',
      seltype => 'tmpfs_t'
    }

    file { $lmsrp::rp_instance_www_error_path:
      ensure => $lmsrp::dir_ensure,
      owner  => nginx,
      group  => nginx,
      mode   => '0700',
    }
  }
