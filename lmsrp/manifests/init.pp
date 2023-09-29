# == Class: lmsrp
#
# NGINX Reverse proxy for LMS/Moodle
#
# === Parameters
#
# Document parameters here.
#
# [server_name]
#  Desc: Hostname header for target application
#  Args: <string>
#  Default: 'localhost'
#
# [server_port]
#  Desc: Port for RP to liste on
#  Args: <integer>
#  Default: 80
#
# [upstream_servers]
#  Desc: Upstream Servers to proxy connection to
#  Args: <array>
#  Default: ['localhost']
#
# [rp_path]
#  Desc: File system path to the main rp application directory
#  Args: <string>
#  Default: '/rp0'
#
# [rp_cache_path]
#  Desc: File system path to the proxy cache
#  Args: <string>
#  Default: '/${rp_path}/cache0'
#
# [rp_log_path]
#  Desc: File system path to the proxy cache
#  Args: <string>
#  Default: '/${rp_path}/logs'
#
# [rp_error_log_level]
#  Desc: nginx error logging level
#  Args: <string>
#  Default: 'info'
#
# [rp_cache_size]
#  Desc: Size of the proxy cache
#  Args: <string>
#  Default: '1G'
#
# [rp_cache_inactive]
#  Desc: NGINX rp_cache inactive parameter
#  Args: <string>
#  Default: '24h'
#
# [rp_cache_keysize]
#  Desc: NGINX rp_cache keysize parameter
#  Args: <string>
#  Default: '10m'
#
# [rp_cache_valid_200]
#  Desc: NGINX rp_cache_valid 200 parameter
#  Args: <string>
#  Default: '60m'
#
# === Variables
#
# === Examples
#
#  class { 'lmsrp':
#    rp_host => 'load.lo.unisa.edu.au'
#    upstream_servers => [ 'itull-lms8a.cw.unisa.edu.au',
#                          'itull-lms8b.cw.unisa.edu.au',
#                          'itull-lms8c.ml.unisa.edu.au',
#                          'itull-lms8d.ml.unisa.edu.au' ],
#
#  }
#
class lmsrp (
  $enabled = $lmsrp::params::enabled,
  $rp_name = undef,
  $rp_port = $lmsrp::params::rp_port,
  $upstream_servers_ml = $lmsrp::params::upstream_servers_ml,
  $upstream_servers_cw = $lmsrp::params::upstream_servers_cw,
  $rp_user = $lmsrp::params::rp_user,
  $rp_group = $lmsrp::params::rp_group,
  $rp_path = undef,
  $rp_log_path = undef,
  $rp_cache_path = undef,
  $rp_cache_size = $lmsrp::params::rp_cache_size,
  $rp_cache_inactive = $lmsrp::params::rp_cache_inactive,
  $rp_cache_keysize = $lmsrp::params::rp_cache_keysize,
  $rp_cache_valid_200 = $lmsrp::params::rp_cache_valid_200,
  String $nginx_version = 'rh-nginx118',
  String $nginx_previous_version = 'rh-nginx110',
  Boolean $nginx_remove_previous_version = false,
  String $nginx_svc_name = "${nginx_version}-nginx",
  String $nginx_previous_svc_name = "${nginx_previous_version}-nginx",
  String $nginx_install_path = "/opt/rh/${nginx_version}",
  String $nginx_config_path = "/etc/opt/rh/${nginx_version}/nginx",
  Array[String] $pkg_list = [$nginx_version],
  Array[String] $pkg_remove_list = [
    $nginx_previous_version,
    "${nginx_previous_version}-nginx",
    "${nginx_previous_version}-runtime"],
  $nginx_server_tokens = $lmsrp::params::nginx_server_tokens,
  $nginx_lb_method = $lmsrp::params::nginx_lb_method,
  $nginx_worker_processes = $lmsrp::params::nginx_worker_processes,
  $nginx_worker_connections = $lmsrp::params::nginx_worker_connections,
  $nginx_worker_rlimit_nofile = $lmsrp::params::nginx_worker_rlimit_nofile,
  $nginx_proxy_connect_timeout = $lmsrp::params::nginx_proxy_connect_timeout,
  $nginx_proxy_read_timeout = $lmsrp::params::nginx_proxy_read_timeout,
  $nginx_proxy_send_timeout = $lmsrp::params::nginx_proxy_send_timeout,
  $nginx_set_real_ip_from = $lmsrp::params::nginx_set_real_ip_from,
  $nginx_debug_clientmap = $lmsrp::params::nginx_debug_clientmap,
  $nginx_oflinejs_cache_enabled = $lmsrp::params::nginx_oflinejs_cache_enabled,
  $nginx_secret_params = $lmsrp::params::nginx_secret_params,

  # error page config.
  $error_400_title = $lmsrp::params::error_400_title,
  $error_400_heading = $lmsrp::params::error_400_heading,
  $error_400_content = $lmsrp::params::error_400_content,
  $error_400_note = $lmsrp::params::error_400_note,
  $error_400_show_home_btn = $lmsrp::params::error_400_show_home_btn,
  $error_400_show_status_btn = $lmsrp::params::error_400_show_status_btn,
  $error_500_title = $lmsrp::params::error_500_title,
  $error_500_heading = $lmsrp::params::error_500_heading,
  $error_500_content = $lmsrp::params::error_500_content,
  $error_500_note = $lmsrp::params::error_500_note,
  $error_500_show_home_btn = $lmsrp::params::error_500_show_home_btn,
  $error_500_show_status_btn = $lmsrp::params::error_500_show_status_btn,
) inherits lmsrp::params
{

  # We don't need site specific upstream servers anymore,
  # so we just use the CW server.
  $upstream_servers = $upstream_servers_cw

  if ($rp_path == undef) {
    $rp_instance_path = "/${rp_name}"
  } else {
    $rp_instance_path = $rp_path
  }

  if ($rp_log_path == undef) {
    $rp_instance_log_path = "${rp_instance_path}/logs"
  }

  if ($rp_cache_path == undef) {
    $rp_instance_cache_path = "${rp_instance_path}/cache"
  }

  $rp_instance_www_error_path = "${rp_instance_path}/www_error"

  if ($rp_name == undef) {
    $mdl_instance_name = $name
  } else {
    $mdl_instance_name = $rp_name
  }

  if($enabled) {
    $pkg_ensure = 'present'
    $dir_ensure = 'directory'
    $dir_force  = true
    $file_ensure = 'file'
    $svc_ensure  = 'running'
    $svc_enable  = true
    $mnt_ensure  = 'mounted'

    class { 'lmsrp::install': }
    -> class { 'lmsrp::environment::directory': }
    -> class { 'lmsrp::environment::mounts': }
    -> class { 'lmsrp::environment::files': }
    -> class { 'lmsrp::config': }
    ~> class { 'lmsrp::service': }
    -> class { 'lmsrp::uninstall': }
  } else {
    $pkg_ensure = 'absent'
    $dir_ensure = 'absent'
    $dir_force  = true
    $file_ensure = 'absent'
    $svc_ensure  = 'stopped'
    $svc_enable  = false
    $mnt_ensure  = 'absent'

    class { 'lmsrp::service': }
    -> class { 'lmsrp::config': }
    -> class { 'lmsrp::install': }
    -> class { 'lmsrp::environment::mounts': }
    -> class { 'lmsrp::environment::directory': }
    -> class { 'lmsrp::environment::files': }
  }

}
