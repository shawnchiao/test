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
class lmsvstsagent::install inherits lmsvstsagent
{

  # Deploy packages and set up environment.
  package { $lmsvstsagent::pkglist:
    ensure  => $lmsvstsagent::pkgensure,
  }
  -> file { '/etc/profile.d/scl-rh-git29.sh':
    content => 'source scl_source enable rh-git29',
    mode    => '0744',
    owner   => 'root',
    group   => 'root',

  }
  -> exec { 'replace-usr-bin-git':
    unless  => 'test -h /usr/bin/git',
    command => 'ln -s /opt/rh/rh-git29/root/usr/bin/git /usr/bin/git',
    path    => '/usr/bin/',
    user    => 'root',
    group   => 'root',
  }
  file { '/etc/ld.so.conf.d/libcurl-httpd24.conf':
    content => '/opt/rh/httpd24/root/usr/lib64/',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
  -> file { '/etc/profile.d/ldconfig.sh':
    content => "#!/bin/sh\nexport LD_LIBRARY_PATH=/lib:/lib64:/usr/lib64:/usr/lib:/opt/rh/httpd24/root/usr/lib64:\$LD_LIBRARY_PATH\n",
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
  }
  -> exec { 'source /etc/profile.d/ldconfig.sh && ldconfig':
    command => 'ldconfig',
    # Check if libcurl-http module already loaded.
    unless  => 'ldconfig -p|grep -wq libcurl-httpd24.so.4',
    path    => '/usr/sbin:/usr/bin',
    user    => 'root',
    group   => 'root',
  }

  file { [$lmsvstsagent::rootdir, $lmsvstsagent::resourcesdir ]:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0777',
  }

  if ($lmsvstsagent::createagentuser and $lmsvstsagent::agentuser != '' and
      $lmsvstsagent::agentgroup != '' and
      $lmsvstsagent::agentuid != '' and
      $lmsvstsagent::groupuid != '') {
    # Owner of agent(s) and work area.
    user { $lmsvstsagent::agentuser:
      ensure     => present,
      name       => $lmsvstsagent::agentuser,
      uid        => $lmsvstsagent::agentuid,
      shell      => '/bin/bash',
      managehome => true,
      gid        => $lmsvstsagent::agentgid,
      require    => Group[$lmsvstsagent::agentgroup],
    }

    group { $lmsvstsagent::agentgroup:
      ensure => present,
      name   => $lmsvstsagent::agentgroup,
      gid    => $lmsvstsagent::agentgid,
    }
  }

}
