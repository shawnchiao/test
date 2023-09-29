# == Class: redis::params
# Default parameters
class lmsredis::params {

  $enabled = false
  $redisremoveprev = false
  $redisrootdir = '/redisdb'
  $sentrootdir = '/sentinel'
  $redislogdir = '/var/log/redis'
  $tcpbacklog = 65535
  $downafterms = 5000
  $failovertimeout = 60000
  $maxmemory = undef
  $maxmemorypolicy = undef
  $maxmemorysamples = undef
  $redisbind = undef
  $redisport = 6379
  $redisprotectedmode = 'no'
  $redisdaemonize = 'yes'
  $sentport = 16379
  $sentprotectedmode = 'no'
  $sentdaemonize = 'no'
  $notifyservice = false

}
