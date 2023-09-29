# == Class: smtpsink
#
# Full description of class smtpsink here.
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
#  class { 'smtpsink':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2020 Your name here, unless otherwise noted.
#
class smtpsink (
  $smtp_sink_user = 'smtp-sink',
  $smtp_sink_home = '/smtp-sink',                #  /var/log/ontask/mail
  $smtp_sink_service_enable = true,
  $smtp_sink_service_ensure = 'running',
  $smtp_bind_address = '127.0.0.1',              #  10.74.26.20
  $smtp_port = '2525',
  $smtp_max_backlog = '100',
  $smtp_sink_prefix_format = '%%Y%%m%%d_%%H%%M%%S.'
) {

  $systemd_unitfiles_path = '/lib/systemd/system'

  class { 'smtpsink::user': }
  -> class { 'smtpsink::environment': }
  -> class { 'smtpsink::config': }
  ~> class { 'smtpsink::service': }
}
