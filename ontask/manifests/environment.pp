# == Class: ontask::environment
# Creates required directory structure.
class ontask::environment inherits ontask {

  $app_folders = ["${ontask::www_ontask_home}/ontask-web",
                  "${ontask::www_ontask_home}/token-server",
                  "${ontask::www_ontask_home}/simpleQueue"]

  $log_folders = ["${ontask::log_root}/nginx",
                  "${ontask::log_root}/ontask-web",
                  "${ontask::log_root}/token-server",
                  "${ontask::log_root}/simpleQueue"]

  file { [$ontask::www_ontask_root,$ontask::www_ontask_home]:
    ensure => 'directory',
    owner  => $ontask::www_ontask_group,
    group  => $ontask::www_ontask_group,
    mode   => '0750'
  }
  -> file { $app_folders:
    ensure => 'directory',
    #owner  => 'root',
    owner  => $ontask::www_ontask_user,
    group  => $ontask::www_ontask_group,
    mode   => '0640'
  }
  -> file { $ontask::log_root:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }
  -> file {  $log_folders:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }
  -> file {  "${ontask::log_root}/newrelic":
    ensure => 'directory',
    owner  => $ontask::www_ontask_user,
    group  => 'root',
    mode   => '0755'
  }
  -> file { "${ontask::www_ontask_root}/logs":
    ensure => 'link',
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    target => $ontask::log_root
  }
  -> file { '/etc/profile.d/scl_env.sh':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ontask/scl_env_profile.erb')
  }
  -> file { "${ontask::www_ontask_home}/.bashrc":
    ensure  => 'file',
    owner   => $ontask::www_ontask_user,
    group   => $ontask::www_ontask_group,
    mode    => '0644',
    content => template('ontask/scl_env_profile.erb')
  }
}
