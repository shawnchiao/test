# == Class: smtpsink::user
# creates smtp sink user.
class smtpsink::user inherits smtpsink {
  user { $smtpsink::smtp_sink_user:
    ensure  => present,
    home    => $smtpsink::smtp_sink_home,
    shell   => '/sbin/nologin',
    comment => 'Smtp Sink system account',
    name    => $smtpsink::smtp_sink_user,
  }
}
