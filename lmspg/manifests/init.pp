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
class lmspg (

  # Disable this module, by default
  $enabled           = false,

  # Package prefix and package version
  $pgpkgprefix       = 'rh-postgresql',
  $dbversion         = '12',
  $postgrespwd       = '',

  # db instances
  $db_instances      = { },

  # db role instances
  $db_role_instances = { },
)
{

  if ($enabled) {

    $pkgensure = 'present'
    $svcensure = 'running'

    # List of packages to be installed.
    $pkglist = [
      "${pgpkgprefix}${dbversion}-postgresql-server", "${pgpkgprefix}${dbversion}-postgresql-syspaths"
    ]

    # Install the package and setup the service
    class { 'lmspg::install': }
    -> class { 'lmspg::service': }
    -> class { 'lmspg::config': }

    # If a postgres password has been passed in, update the db user
    if ($lmspg::postgrespwd != '') {
      class { 'lmspg::post_install': }
    }

    # Reference common db default
    include lmspg::dbdefaults

    # Add each requested db instance
    if (!empty($db_instances)) {
      create_resources(lmspg::instance, $db_instances)
    }

    # Add each requested db role
    if (!empty($db_role_instances)) {
      create_resources(lmspg::instance_role, $db_role_instances)
    }

  } else {

    $svcensure = 'stopped'
    $pkgensure = 'absent'

  }

}
