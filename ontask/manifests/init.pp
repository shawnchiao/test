# == Class: ontask
# Configures environment for UniSA Ontask
#
# === Parameters
#
# Document parameters here.
#
# [servername]
#   The fully qualified domain name which the service will be accessed
#   from by the client (eg via Reverse proxy or load balancer).
#   This configures the servername parameter for the nginx vhost
#   and is expected to be sent in the Host header by the client.
#   Example : 
#    servername => 'test.ontask-uo.unisa.edu.au',
#
# [www_ontask_user] (Optional)
#   The user which ontask will run as.
#   If the user does not exist on the system it will be created.
#   Default : www-ontask
#   Example : 
#    www_ontask_user => 'www-ontask',
#
# [www_ontask_group] (Optional)
#   The group which ontask will run as.
#   If the group does not exist on the system it will be created.
#   Default : www-ontask
#   Example :
#    www_ontask_group => 'www-ontask',
#
# [www_ontask_root] (Optional)
#   The location to install ontask.
#   If the directory does not exist it will be created.
#   Default : /ontask
#   Example :
#    www_ontask_root => '/ontask',
#
# [www_ontask_service_enable] (Optional)
#   If set to true ontask will be configured to start at boot.
#   It is recommened on first run to set this value to false,
#   as these services will fail to start and may cause puppet,
#   to fail to complete setting up the envrionment correctly.
#   Default : true
#   Example :
#    www_ontask_service_enable => false,
#
# [www_ontask_service_ensure] (Optional)
#   If set to 'running' ontask services will be started by puppet.
#   It is recommended on first run to set this value to 'stopped',
#   as these services will fail to start and may cause puppet,
#   to fail to complete setting up the envrionment correctly.
#   Default : running
#   Example :
#    www_ontask_service_ensure => 'stopped',
#
# [log_root] (Optional)
#   The location store ontask logs.
#   Default : /var/log/ontask
#   Example :
#    log_root => '/var/log/ontask',
#
# [set_real_ip_from] (Optional)
#   When set this X-Forwarded values sent from this array of ip addresses,
#   will be trusted, and considered as the client IP.
#   Set this to be the array of IP addresses of the client IP address of any
#    upstream load balancers, or reverse proxies.
#   Default : ['130.220.101.250']
#   Example :
#    set_real_ip_from => ['130.220.1.250'',130.220.1.251','130.220.1.252'],
#
# [nodejs_version] (Optional)
#   The nodejs version to use (as named in Red Hat Software collections).
#   The version specified here will be installed, and defined to launch
#   node applications by defining it in /bin/scl enable ${nodejs_version}
#   Default : rh-nodejs10
#   Example :
#    nodejs_version => 'rh-nodejs10',
#
# [ruby_version] (Optional)
#   The ruby version to use (as named in Red Hat Software collections).
#   The version specified here will be installed, and defined to launch
#   node applications by defining it in /bin/scl enable ${ruby_version}
#   Default : rh-ruby24
#   Example :
#    ruby_version => 'rh-ruby24',
#
# [nginx_version] (Optional)
#   The nginx version to use (as named in Red Hat Software collections).
#   Default : rh-nginx116
#   Example :
#    nginx_version => 'rh-nginx116',
#
# [python_version] (Optional)
#   The ruby version to use (as named in Red Hat Software collections).
#   The version specified here will be installed, and defined to launch
#   node applications by defining it in /bin/scl enable ${python_version}
#   Default : rh-python36
#   Example :
#    python_version => 'rh-python36',
#
# [oracle_version] (Optional)
#   The oracle version to use.
#   Default : 18.3
#   Example :
#    oracle_version => '18.3',
#
# [systemd_unitfiles_path] (Optional)
#   The path to install systemd unit files.
#   Default : /lib/systemd/system
#   Example :
#    systemd_unitfiles_path => '/lib/systemd/system',
#
# [nodejs_environment] (Optional)
#   The nodejs environment to set, which determines
#     which config files to use. (eg 'development', 'test', 'production')
#   Default : development
#   Example :
#    nodejs_environment => 'development',
#
# [newrelic_licence_key] (Optional)
#   The new relic licne key.
#   Default : 
#   Example :
#    newrelic_licence_key => '',
#
# [newrelic_app_name] (Optional)
#   The new relic application name.
#   Default : 
#   Example :
#    newrelic_app_name => 'Ontask (Prod)',
#
class ontask(
  $server_name,
  $www_ontask_user = 'www-ontask',
  $www_ontask_group = 'www-ontask',
  $www_ontask_root = '/ontask',
  $www_ontask_service_enable = true,
  $www_ontask_service_ensure = 'running',
  $log_root = '/var/log/ontask',
  $set_real_ip_from = '130.220.101.250',
  $nodejs_version = 'rh-nodejs10',
  $ruby_version = 'rh-ruby24',
  $nginx_version = 'rh-nginx116',
  $python_version = 'rh-python36',
  $systemd_unitfiles_path = '/lib/systemd/system',
  $oracle_version = '18.3',
  $nodejs_environment = 'development',
  $newrelic_licence_key = '',
  $newrelic_app_name = '',
) {

  $pkg_list = [$nodejs_version,
              $python_version,
              'rh-redis5',
              $nginx_version,
              'rh-git218',
              $ruby_version,
              "${ruby_version}-ruby-devel",
              'gcc',
              "oracle-instantclient${oracle_version}-basic"]

  $pkg_ensure = 'present'
  $www_ontask_home = "${www_ontask_root}/www"
  $nginx_config_path = "/etc/opt/rh/${nginx_version}/nginx"
  $tnsnames_dir = "/usr/lib/oracle/${oracle_version}/client64/lib/network/admin/"
  class { 'ontask::user': }
  -> class { 'ontask::install': }
  -> class { 'ontask::environment': }
  -> class { 'ontask::config': }
  ~> class { 'ontask::service': }
}
