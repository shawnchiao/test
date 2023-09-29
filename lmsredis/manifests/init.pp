# Class: redis
# ===========================
#
# UniSA Specific Puppet class used to build Redis Cluster.
#
# Parameters
# ----------
#
# [sentmaster]
#  Desc: Short Host name of the sentinel witness/tiebreaker server.
#  Args: <string>
#
# [redismaster]
#  Desc: Fully qualtified Host name of the master redis/sentinel server.
#        This server should be configured in the cluster first.
#  Args: <string>
#
# [quorumnum]
#  Desc: The minimum number of votes required in the cluster to establish quorum.
#  Args: <int>
#
# [replicapriority]
#  Desc: I hash defining the failover priority of servers int the cluster.
#        Lower numbers will be promoted to master abover higher numbers.
#  Args: <hiera_hash>
#  Example :
#   replicapriority => {
#    'itupl-lrnredis1a.cw.unisa.edu.au' => '10',
#    'itupl-lrnredis1b.cw.unisa.edu.au' => '20',
#    'itupl-lrnredis2a.ml.unisa.edu.au' => '50',
#  },
#
# Variables
# ----------
# Examples
# --------
#
# @example
#  class { 'redis':
#    enabled         => true,
#    quorumnum       => 3,
#    redismaster     => 'itupl-lrnredis1a.cw.unisa.edu.au',
#    replicapriority => {
#      'itupl-lrnredis1a.cw.unisa.edu.au' => '10',
#      'itupl-lrnredis1b.cw.unisa.edu.au' => '20',
#      'itupl-lrnredis2a.ml.unisa.edu.au' => '50',
#    },
#    sentmaster      => 'itupl-lrnsntl1'
#  }
#
class lmsredis (
  String $sentmaster,
  String $redismaster,
  Integer $quorumnum,
  String $redisversion = 'rh-redis5',
  String $redisprevversion = '',
  String $redissrv = "${redisversion}-redis",
  String $sentsrv  = "${redisversion}-redis-sentinel",
  Array[String] $pkglist = [ $redisversion, "${redisversion}-runtime" ],
  Boolean $redisremoveprev = $lmsredis::params::redisremoveprev,
  Array[String] $prevpkglist = [ $redisprevversion, "${redisprevversion}-runtime" ],
  String $prevredissrv = "${redisprevversion}-redis",
  String $prevsentsrv = "${redisprevversion}-redis-sentinel",
  String $redisinstalldir = "/opt/rh/${redisversion}",
  String $redisconfigpath = "/etc/opt/rh/${redisversion}",
  Boolean $enabled = $lmsredis::params::enabled,
  String $redisrootdir = $lmsredis::params::redisrootdir,
  String $redislogdir  = $lmsredis::params::redislogdir,
  Integer $tcpbacklog = $lmsredis::params::tcpbacklog,
  Integer $downafterms = $lmsredis::params::downafterms,
  Integer $failovertimeout = $lmsredis::params::failovertimeout,
  Optional[String] $redisbind = $lmsredis::params::redisbind,
  Integer $redisport = $lmsredis::params::redisport,
  Enum['yes', 'no'] $redisprotectedmode = $lmsredis::params::redisprotectedmode,
  Enum['yes', 'no'] $redisdaemonize = $lmsredis::params::redisdaemonize,
  Optional[String] $maxmemory = $lmsredis::params::maxmemory,
  Optional[Enum['volatile-lru', 'allkeys-lru', 'volatile-lfu', 'allkeys-lfu', 'volatile-random',
    'allkeys-random', 'volatile-ttl', 'noeviction']] $maxmemorypolicy = $lmsredis::params::maxmemorypolicy,
  Optional[Integer[1, 10]] $maxmemorysamples = $lmsredis::params::maxmemorysamples,
  Integer $sentport = $lmsredis::params::sentport,
  Enum['yes', 'no'] $sentprotectedmode = $lmsredis::params::sentprotectedmode,
  Enum['yes', 'no'] $sentdaemonize = $lmsredis::params::sentdaemonize,
  Hash[String,Integer] $replicapriority = lookup({ name => 'lmsredis::replicapriority', value_type => Hash, default_value => {}}),
  Boolean $selinux_ignore_defaults = true,
  Boolean $notifyservice = $lmsredis::params::notifyservice,
) inherits lmsredis::params {
  if ($enabled) {
    package { $pkglist :
      ensure => 'present',
    }
    -> class { 'lmsredis::logs': }
    -> class { 'lmsredis::config': }
    -> class { 'lmsredis::env': }
    -> class { 'lmsredis::uninstall': }
    ~> class { 'lmsredis::service': }
  }
}
