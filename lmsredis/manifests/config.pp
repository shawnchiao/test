# == Class: redis::config
# Configures redis
class lmsredis::config inherits lmsredis {
  # Set File Defaults.
  # We set selinux_ignore_defaults to avoid restarting the service because we weren't manageing these in puppet 3.
  File {
    selinux_ignore_defaults => $lmsredis::selinux_ignore_defaults
  }

  $sentconfigfilename = "${lmsredis::redisconfigpath}/redis-sentinel.conf"
  $sentconfigfilenameorig  ="${lmsredis::redisconfigpath}/redis-sentinel.conf.original"

  if ($lmsredis::notifyservice) {
    Exec["copy ${sentconfigfilenameorig} to ${sentconfigfilename}"] ~> Service[$lmsredis::sentsrv]
  } else {
    Exec["copy ${sentconfigfilenameorig} to ${sentconfigfilename}"] -> Service[$lmsredis::sentsrv]
  }

  file { $sentconfigfilenameorig:
    ensure  => 'file',
    content => template("lmsredis/${lmsredis::redisversion}/redis-sentinel.conf.erb"),
    owner   => 'redis',
    group   => 'root',
    mode    => '0640',
  }

  # Copy updated config file if changes detected.
  exec { "copy ${sentconfigfilenameorig} to ${sentconfigfilename}":
    path        => '/usr/bin:/bin',
    command     => "cp -p ${sentconfigfilenameorig} ${sentconfigfilename}",
    subscribe   => File[$sentconfigfilenameorig],
    refreshonly => true,
  }

  $redisconfigfilename = "${lmsredis::redisconfigpath}/redis.conf"
  $redisconfigfilenameorig  ="${lmsredis::redisconfigpath}/redis.conf.original"

  if ($lmsredis::notifyservice) {
    Exec["copy ${redisconfigfilenameorig} to ${redisconfigfilename}"] ~> Service[$lmsredis::redissrv]
  } else {
    Exec["copy ${redisconfigfilenameorig} to ${redisconfigfilename}"] -> Service[$lmsredis::redissrv]
  }

  file { $redisconfigfilenameorig:
    ensure  => 'file',
    content => template("lmsredis/${lmsredis::redisversion}/redis.conf.erb"),
    owner   => 'redis',
    group   => 'root',
    mode    => '0640',
  }

  # Copy updated config file if changes detected.
  exec { "copy ${redisconfigfilenameorig} to ${redisconfigfilename}":
    path        => '/usr/bin:/bin',
    command     => "cp -p ${redisconfigfilenameorig} ${redisconfigfilename}",
    subscribe   => File[$redisconfigfilenameorig],
    refreshonly => true,
  }

}
