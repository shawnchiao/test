# == Type: lmspg::instance_role
#
# Full description of type lmspg::instance_role here.
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
#   create_resources(lmspg::instance_role, {'a' => { dbuser => 'abc', dbpassword => 'dbuser'})
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2018 Your name here, unless otherwise noted.
#
define lmspg::instance_role (
  $dbuser            = $name,
  $dbpassword        = $lmspg::dbdefaults::defaultpwd,
)
{
  # Create DB role.
  exec { "create-user-${name}-${dbuser}":
    unless  => "psql -U postgres -t -c '\\du' | cut -d \\| -f 1 | grep -qw ${dbuser}",
    path    => ['/bin', '/usr/bin'],
    command => "psql -U postgres -c \"CREATE USER ${dbuser} WITH PASSWORD '${dbpassword}';\"",
    require => Service["${lmspg::pgpkgprefix}${lmspg::dbversion}-postgresql"],
  }

}
