# == Class: smtpsink::config
# Configures SMTP Sink
class smtpsink::config inherits smtpsink {
  file { "${smtpsink::systemd_unitfiles_path}/unisa-smtp-sink.service":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('smtpsink/unisa-smtp-sink.service.erb'),
    notify  => Exec['smtpsink_systemd_daemon_reload']
  }

  exec { 'smtpsink_systemd_daemon_reload':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
    user        => 'root'
  }
}
