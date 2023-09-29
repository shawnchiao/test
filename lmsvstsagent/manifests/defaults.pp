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
class lmsvstsagent::defaults
{
    # Agent version
    $buildagentversion = '2.133.3'

    # Agent user
    $user = $lmsvstsagent::params::agentuser
    $uid = $lmsvstsagent::params::agentuid
    $group = $lmsvstsagent::params::agentgroup
    $gid = $lmsvstsagent::params::agentgid
    # Default behaviour expects user creation to occur externally.
    $createuser = false

    # VSTS account name
    $account = 'universityofsouthaustralia'

    # VSTS project name
    $project = 'Learning and Teaching Systems'

    # VSTS Queue name
    $poolqueue = ''

    # VSTS Deployment queue name
    $deploygroup = ''

    # VSTS Private Auth Token
    $authtoken = ''

    # VSTS Agent name - default = $hostname-$name
    # * should contain valid filename characters & no whitespace
    $agentname = ''

    # Additional config.sh params
    $configparams = ''

    # Comma seperated list
    $tags = ''
}
