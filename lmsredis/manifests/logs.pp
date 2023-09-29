# == Class: redis::logs
# Sets up log file locations
class lmsredis::logs inherits lmsredis {

  file { $lmsredis::redislogdir:
    ensure => 'directory',
    owner  => 'redis',
    group  => 'redis',
    mode   => '0660'
  }

  file { "${lmsredis::redislogdir}/redis.log":
    ensure => 'file',
    owner  => 'redis',
    group  => 'redis',
    mode   => '0660'
  }

  file { "${lmsredis::redislogdir}/sentinel.log":
    ensure => 'file',
    owner  => 'redis',
    group  => 'redis',
    mode   => '0660'
  }

  file { "/etc/logrotate.d/${lmsredis::redissrv}":
    ensure  => 'file',
    content => template('lmsredis/logrotate-redis.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }

}
