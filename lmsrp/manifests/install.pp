# == Class: lmsrp::install
#
# Installs required packages for nginx reverse proxy
#
# === Parameters
#  None
# === Variables
#  None
# === Examples
#
#  class { 'lmsrp::install':
#  }
#
class lmsrp::install inherits lmsrp
{
  $pkg_list = $lmsrp::pkg_list
  $pkg_ensure = $lmsrp::pkg_ensure
  #install packages
  package { $pkg_list :
      ensure => $pkg_ensure,
  }
}
