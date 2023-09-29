# == Class: lmsvstsagent
#
# Full description of class lmsvstsagent here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'lmsvstsagent':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class lmsvstsagent (

  # General
  $enabled = $lmsvstsagent::params::enabled,
  $pkglist = $lmsvstsagent::params::pkglist,

  # VSTS agents
  $agent_instances = $lmsvstsagent::params::agent_instances,

  # HTTP proxy.
  $proxyhost = $lmsvstsagent::params::proxyhost,
  $proxyport = $lmsvstsagent::params::proxyport,

  # Base dirs.
  $rootdir = $lmsvstsagent::params::rootdir,
  $resourcesdir = $lmsvstsagent::params::resourcesdir,

  # Allow a single user account to be created and shared among agents.
  $createagentuser = $lmsvstsagent::params::createagentuser,
  $agentuser = $lmsvstsagent::params::agentuser,
  $agentuid = $lmsvstsagent::params::agentuid,
  $agentgroup = $lmsvstsagent::params::agentgroup,
  $agentgid = $lmsvstsagent::params::agentgid,

) inherits lmsvstsagent::params
{
  require lmsvstsagent::defaults

  if($enabled) {

    $pkgensure = 'present'
    $svcensure = 'running'

    class { 'lmsvstsagent::install': }
    -> class { 'lmsvstsagent::service': }
    -> class { 'lmsvstsagent::config': }

    create_resources(lmsvstsagent::instance, $agent_instances)

  } else {

    $svcensure = 'stopped'
    $pkgensure = 'absent'

  }

}
