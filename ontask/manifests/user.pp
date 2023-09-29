# == Class: ontask::user
# Creates any necessary users.
class ontask::user inherits ontask {
  user { $ontask::www_ontask_user:
    ensure  => present,
    home    => $ontask::www_ontask_home,
    shell   => '/sbin/nologin',
    comment => 'OnTask system account',
    name    => $ontask::www_ontask_user
  }
}
