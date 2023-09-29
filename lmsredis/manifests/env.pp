# == Class: redis::env
# Configures redis
class lmsredis::env inherits lmsredis {

  exec { 'exec_lmsredis_disable_thp':
    path    => '/bin',
    command => 'echo never > /sys/kernel/mm/transparent_hugepage/enabled',
    unless  => 'grep "\[never\]$" /sys/kernel/mm/transparent_hugepage/enabled',
  }

  exec { 'exec_lmsredis_disable_thp_defrag':
    path    => '/bin',
    command => 'echo never > /sys/kernel/mm/transparent_hugepage/defrag',
    unless  => 'grep "\[never\]$" /sys/kernel/mm/transparent_hugepage/defrag',
  }

  file { '/etc/profile.d/redisalias.sh':
    ensure  =>  'file',
    owner   =>  'root',
    mode    =>  '0644',
    group   =>  'root',
    content => template('lmsredis/redisalias.sh.erb'),
  }

  file { $lmsredis::redisrootdir:
    ensure => 'directory',
    owner  => 'redis',
    mode   => '0640',
  }

  file { $lmsredis::sentrootdir:
    ensure => 'directory',
    owner  => 'redis',
    mode   => '0640',
  }

}
