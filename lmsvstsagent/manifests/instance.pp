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
define lmsvstsagent::instance (
  $buildagentversion = $lmsvstsagent::defaults::buildagentversion,
  $user = $lmsvstsagent::defaults::user,
  $group = $lmsvstsagent::defaults::group,
  $uid = $lmsvstsagent::defaults::uid,
  $gid = $lmsvstsagent::defaults::gid,
  $createuser = $lmsvstsagent::defaults::createuser,
  $account = $lmsvstsagent::defaults::account,
  $project = $lmsvstsagent::defaults::project,
  $poolqueue = $lmsvstsagent::defaults::poolqueue,
  $deploygroup = $lmsvstsagent::defaults::deploygroup,
  $authtoken = $lmsvstsagent::defaults::authtoken,
  $agentname = $lmsvstsagent::defaults::agentname,
  $configparams = $lmsvstsagent::defaults::configparams,
  $tags = $lmsvstsagent::defaults::tags,
) {

  if ($agentname != '') {
    $instancename = $agentname
  } else {
    $instancename = "${::hostname}-${name}"
  }

  $instancedir = "${lmsvstsagent::rootdir}/${instancename}"
  $agentdir = "${lmsvstsagent::rootdir}/${instancename}/agent"
  $workdir = "${lmsvstsagent::rootdir}/${instancename}/work"

  if ($poolqueue != '') {
    $poolqueueargs = "--pool '${poolqueue}'"
  } else {
    $poolqueueargs = ''
  }

  if ($deploygroup != '') {
    $deploygroupargs = "--deploymentgroup --deploymentgroupname '${deploygroup}'"
  }

  if ($lmsvstsagent::proxyhost != '') {
    $proxyargs = "--proxyurl http://${lmsvstsagent::proxyhost}:${lmsvstsagent::proxyport}"
    $proxyenv = [
      "http_proxy=http://${lmsvstsagent::proxyhost}:${lmsvstsagent::proxyport}",
      "https_proxy=https://${lmsvstsagent::proxyhost}:${lmsvstsagent::proxyport}"
    ]
  } else {
    $proxyargs = ''
    $proxyenv = []
  }

  if ($tags != '') {
    $tagargs = "--addDeploymentGroupTags --deploymentGroupTags '${tags}'"
  } else {
    $tagargs = ''
  }

  if ($createuser) {
    # Create owner of agent and work area.
    user { "${instancename}-${user}":
      ensure     => present,
      name       => $user,
      uid        => $uid,
      shell      => '/bin/bash',
      managehome => true,
      gid        => $gid,
      require    => Group[$instancename-$group],
    }

    group { "${instancename}-${group}":
      ensure => present,
      name   => $group,
      gid    => $gid,
    }
  }

  # Agent and work directories.
  file { [ $instancedir, $agentdir, $workdir ]:
    ensure  => 'directory',
    owner   => $user,
    group   => $group,
    require => [ File[$lmsvstsagent::rootdir] ],
    mode    => '0755',
  }

  # Download => /tmp/vsts-agent-linux-x64-nn.n.tar.gz
  exec { "${instancename}-download-build-agent":
    command     => "wget https://vstsagentpackage.azureedge.net/agent/${buildagentversion}/vsts-agent-linux-x64-${buildagentversion}.tar.gz -O /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
    path        => '/usr/bin',
    unless      => "test -f ${agentdir}/config.sh",
    environment => $proxyenv,
  }
  -> exec { "${instancename}-download-build-agent-permissions":
    command => "chmod 777 /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
    path    => '/usr/bin',
    onlyif  => "test -f /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
  }
  -> exec { "${instancename}-extract-build-agent":
    command => "tar xf /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
    path    => '/usr/bin',
    cwd     => $agentdir,
    user    => $user,
    group   => $group,
    require => [ File[$agentdir] ],
    onlyif  => "test -f /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
  }
  -> exec { "${instancename}-delete-build-agent-tarball":
    command => "rm /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
    path    => '/usr/bin',
    onlyif  => "test -f /tmp/${instancename}-vsts-agent-linux-x64-${buildagentversion}.tar.gz",
  }

  # Unnattended agent configuration.
  exec { "${instancename}-configure-build-agent":
    command => "${agentdir}/config.sh --unattended --url https://${account}.visualstudio.com --auth pat --token ${authtoken} \
                    --agent '${instancename}' --work '${workdir}' --projectname '${project}' \
                    ${poolqueueargs} ${deploygroupargs} \
                    ${tagargs} \
                    ${proxyargs} \
                     --runasservice --acceptTeeEula ${configparams} \
                     --replace",
    unless  => "test -f ${agentdir}/.agent",
    path    => '/usr/bin',
    user    => $user,
    group   => $group,
    require => [ Exec["${instancename}-extract-build-agent"] ],
  }

  # Install systemd service (configured to runas $user).
  exec { "${instancename}-install-build-agent-service":
    command => "${agentdir}/svc.sh install ${user}",
    path    => '/usr/bin',
    unless  => "test -f ${agentdir}/runsvc.sh",
    cwd     => $agentdir,
    user    => 'root',
    group   => 'root',
    require => [ Exec["${instancename}-configure-build-agent"] ],
  }

  service { "vsts.agent.${account}.${instancename}.service":
    ensure  => $lmsvstsagent::svcensure,
    require => Exec["${instancename}-install-build-agent-service"]
  }

}
