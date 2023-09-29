# == Class: lmsrp::params
#
# Contains default parameters for lmsrp
#
# === Parameters
#  None
# === Variables
#  None
# === Examples
#
#  class { 'lmsrp::params':
#  }
#
class lmsrp::params {
  $enabled = true
  $rp_port = '80'
  $upstream_servers_ml = ['localhost']
  $upstream_servers_cw = ['localhost']
  $rp_error_log_level = 'info'
  $rp_cache_size = '1G'
  $rp_cache_inactive = '24h'
  $rp_cache_keysize = '10m'
  $rp_cache_valid_200 = '60m'
  $rp_user = 'nginx'
  $rp_group = 'nginx'
  $nginx_server_tokens = 'off'
  $nginx_lb_method = 'least_conn'
  $nginx_worker_processes = 1
  $nginx_worker_connections = 1024
  $nginx_worker_rlimit_nofile = 1024
  $nginx_proxy_connect_timeout = '60s'
  # 1 hour timeout to handle long running edge cases such as backup/restore.
  $nginx_proxy_read_timeout = '3600s'
  $nginx_proxy_send_timeout = '60s'
  $nginx_set_real_ip_from = []
  $nginx_debug_clientmap = []
  $nginx_oflinejs_cache_enabled = false
  $nginx_secret_params = ['token', 'wstoken']

  # error page config.
  $error_400_title = 'Page or resource not available'
  $error_400_heading = 'Page or resource not available!'
  $error_400_content = 'The page or resource requested is not available as it does not exist or you do not have permission to access it.'
  $error_400_note = undef
  $error_400_show_home_btn = true
  $error_400_show_status_btn = false
  $error_500_title = 'Something went wrong'
  $error_500_heading = 'Something went wrong!'
  $error_500_content = 'An unexpected error has occured, please try again later.'
  $error_500_note = undef
  $error_500_show_home_btn = true
  $error_500_show_status_btn = true
}
