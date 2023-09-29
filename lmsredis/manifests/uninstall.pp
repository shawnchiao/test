# == Class lmsweb::uninstall
# Installs required packages for an nginx/php webserver
class lmsredis::uninstall inherits lmsredis
{
  if ($lmsredis::redisremoveprev) {
    package { $lmsredis::prevpkglist :
      ensure => 'purged'
    }
    -> file { [
      "/etc/opt/rh/${lmsredis::redisprevversion}",
      "/etc/logrotate.d/${lmsredis::redisprevversion}-redis",
      "/etc/logrotate.d/${lmsredis::redisprevversion}-redis.rpmsave"
    ]:
      ensure  => 'absent',
      recurse => true,
      force   => true
    }
  }

}
