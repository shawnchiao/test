# == Type: lmspg::instance
#
# Full description of type lmspg::instance here.
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
#   create_resources(lmspg::instance, {'a' => { dbname => 'abc', dbuser => 'dbuser'})
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2018 Your name here, unless otherwise noted.
#
define lmspg::instance (
  $dbname            = $name,
  $dbowner           = $lmspg::dbdefaults::dbowner,
  $dbownerpwd        = $lmspg::dbdefaults::defaultpwd,
)
{
  # Create DB Owner.
  exec { "create-owner-${dbname}-${dbowner}":
    unless  => "psql -U postgres -t -c '\\du' | cut -d \\| -f 1 | grep -qw ${dbowner}",
    path    => ['/bin', '/usr/bin'],
    command => "psql -U postgres -c \"CREATE USER ${dbowner} WITH PASSWORD '${dbownerpwd}';\"",
    require => Service["${lmspg::pgpkgprefix}${lmspg::dbversion}-postgresql"],
  }

  # Create DB.
  exec { "create-db-${dbname}":
    unless  => "psql -U postgres -lqt | cut -d \\| -f 1 | grep -qw ${dbname}",
    path    => ['/bin', '/usr/bin'],
    command => "createdb -U postgres ${dbname} --owner ${dbowner}",
    require => [ Service["${lmspg::pgpkgprefix}${lmspg::dbversion}-postgresql"], Exec["create-owner-${dbname}-${dbowner}"] ],
  }

}
