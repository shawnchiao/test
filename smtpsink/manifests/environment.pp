# == Class: smtpsink::environment
# Creates required directory structure
class smtpsink::environment inherits smtpsink {
  file { [$smtpsink::smtp_sink_home]:
    ensure => directory,
    owner  => $smtpsink::smtp_sink_user,
    group  => $smtpsink::smtp_sink_user,
    mode   => '0755'
  }
}
