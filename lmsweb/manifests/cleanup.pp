# == Class lmsweb::cleanup
# Cleans up extraneous resources created by previous versions of this puppet module.
class lmsweb::cleanup inherits lmsweb
{
  file { [
      "/etc/profile.d/scl-${lmsweb::php_previous_version}.sh",
      "/etc/profile.d/scl-${lmsweb::php_version}.sh",
    ]:
    ensure => 'absent'
  }
}
