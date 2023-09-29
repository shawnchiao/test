# == Class: redis::service
# Configures redis & redis-sentinel services
class lmsredis::service inherits lmsredis {

  # Make sure previous services are stopped
  service { $lmsredis::prevredissrv:
    ensure => 'stopped',
    enable => false
  }
  service { $lmsredis::prevsentsrv:
    ensure => 'stopped',
    enable => false
  }

  if ($::hostname == $lmsredis::sentmaster)  {
    $srvensure = 'stopped'
  } else {
    $srvensure = 'running'
  }
  # Make sure Redis is running on redis active and replica nodes only. Service is not enabled its not started on server
  # reboots, this approach is so Redis is not started on sentmaster (which is only for sentinel quorom).
  service { $lmsredis::redissrv:
    ensure => $srvensure,
    enable => false
  }

  # Make sure Sentinel is started
  service { $lmsredis::sentsrv:
    ensure => 'running',
    enable => false
  }

}
