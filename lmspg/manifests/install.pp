# == Class: lmspg
#
# Full description of class lmspg here.
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
#  class { 'lmspg':
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
class lmspg::install inherits lmspg
{

  # Deploy packages and set up environment.
  package { $lmspg::pkglist:
    ensure  => $lmspg::pkgensure,
  }

  # Init postgres.
  exec { 'initdb':
    creates => "/var/opt/rh/${lmspg::pgpkgprefix}${lmspg::dbversion}/lib/pgsql/data/global",
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
    command => "/opt/rh/${lmspg::pgpkgprefix}${lmspg::dbversion}/root/usr/bin/postgresql-setup initdb",
    user    => 'root',
    require => [ Package["${lmspg::pgpkgprefix}${lmspg::dbversion}-postgresql-server"] ],
  }
  -> file { 'pg_hba':
    ensure => present,
    notify => Service["${lmspg::pgpkgprefix}${lmspg::dbversion}-postgresql"],
    path   => "/var/opt/rh/${lmspg::pgpkgprefix}${lmspg::dbversion}/lib/pgsql/data/pg_hba.conf",
    source => 'puppet:///modules/lmspg/pg_hba.conf',
    owner  => 'postgres',
    group  => 'postgres',
    mode   => '0600',
  }
  -> file { 'postgresql.conf':
    ensure => present,
    notify => Service["${lmspg::pgpkgprefix}${lmspg::dbversion}-postgresql"],
    path   => "/var/opt/rh/${lmspg::pgpkgprefix}${lmspg::dbversion}/lib/pgsql/data/postgresql.conf",
    source => 'puppet:///modules/lmspg/postgresql.conf',
    owner  => 'postgres',
    group  => 'postgres',
    mode   => '0600',
  }

}
