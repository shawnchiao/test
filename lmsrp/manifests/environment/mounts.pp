# == Class: lmsrp::environment::mounts
#
# Creates tmpfs ram disk for reverse proxy cache.
#
# === Parameters
#  None
# === Variables
#  None
# === Examples
#
#  class { 'lmsrp::environment::mounts':
#  }
#
class lmsrp::environment::mounts inherits lmsrp
{
  mount { $lmsrp::rp_instance_cache_path:
          ensure  => $lmsrp::mnt_ensure,
          device  => tmpfs,
          fstype  => tmpfs,
          options => "size=${lmsrp::rp_cache_size},uid=${lmsrp::rp_user},gid=${lmsrp::rp_group},mode=0700",
        }
}
