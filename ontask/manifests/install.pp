# == Class: ontask::install
# Installs required packages.
class ontask::install inherits ontask {
  #install packages
  package { $ontask::pkg_list :
    ensure => $ontask::pkg_ensure,
  }
  -> exec {'install_ruby_sass_gem':
    command => "/usr/bin/scl enable ${ontask::ruby_version} 'gem install sass'",
    creates => "/opt/rh/${ontask::ruby_version}/root/usr/local/bin/sass",
    user    => 'root',
    umask   => '0022'
  }
  -> exec {'install_npm_bower':
    command => "/usr/bin/scl enable ${ontask::nodejs_version} 'npm install bower@latest -g'",
    creates => "/opt/rh/${ontask::nodejs_version}/root/usr/bin/bower",
    user    => 'root',
    umask   => '0022'
  }
  -> exec {'install_npm_grunt':
    command => "/usr/bin/scl enable ${ontask::nodejs_version} 'npm install grunt@latest -g'",
    creates => "/opt/rh/${ontask::nodejs_version}/root/usr/bin/grunt",
    user    => 'root',
    umask   => '0022'
  }
  -> exec {'install_pip_pandas':
    command => "/usr/bin/scl enable ${ontask::python_version} 'pip install --upgrade pip && pip install pandas'",
    unless  => "/usr/bin/scl enable ${ontask::python_version} 'pip list | /bin/grep pandas'",
    user    => 'root',
    umask   => '0022'
  }
  -> exec {'install_pip_matplotlib':
    command => "/usr/bin/scl enable ${ontask::python_version} 'pip install --upgrade pip && pip install matplotlib'",
    unless  => "/usr/bin/scl enable ${ontask::python_version} 'pip list | /bin/grep matplotlib'",
    user    => 'root',
    umask   => '0022'
  }
  -> exec {'install_pip_seaborn':
    command => "/usr/bin/scl enable ${ontask::python_version} 'pip install --upgrade pip && pip install seaborn'",
    unless  => "/usr/bin/scl enable ${ontask::python_version} 'pip list | /bin/grep seaborn'",
    user    => 'root',
    umask   => '0022'
  }
    -> exec {'install_pip_requests':
    command => "/usr/bin/scl enable ${ontask::python_version} 'pip install --upgrade pip && pip install requests'",
    unless  => "/usr/bin/scl enable ${ontask::python_version} 'pip list | /bin/grep requests'",
    user    => 'root',
    umask   => '0022'
  }
}
