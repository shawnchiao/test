# == Class: smtpsink::service
# Configures SMTP Sink services.
class smtpsink::service inherits smtpsink {
  service {'unisa-smtp-sink':
    ensure => $smtpsink::smtp_sink_service_ensure,
    enable => $smtpsink::smtp_sink_service_enable,
  }
}
