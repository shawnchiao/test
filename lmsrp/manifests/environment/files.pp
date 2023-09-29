# == Class: lmsrp::environment::files
#
# Configure custom error pages.
#
# === Parameters
#  None
# === Variables
#  None
# === Examples
#
#  class { 'lmsrp::environment::files':
#  }
#
class lmsrp::environment::files inherits lmsrp
  {
    file { "${lmsrp::rp_instance_www_error_path}/400.html":
      ensure  => $lmsrp::file_ensure,
      content => template('lmsrp/www_error/400.html.erb'),
      mode    => '0400',
      owner   => nginx,
      group   => nginx,
    }
    file { "${lmsrp::rp_instance_www_error_path}/500.html":
      ensure  => $lmsrp::file_ensure,
      content => template('lmsrp/www_error/500.html.erb'),
      mode    => '0400',
      owner   => nginx,
      group   => nginx,
    }
  }
