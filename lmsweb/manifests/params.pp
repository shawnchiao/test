# == Class lmsweb::params
# Default parameters
class lmsweb::params
{
  $enabled = false

  # nginx/fpm user
  $www_user = 'www-mdl'
  $www_group = 'www-mdl'

  # fpm config
  $fpm_pm = 'dynamic'
  $fpm_pm_max_children = 75
  $fpm_pm_start_servers = 5
  $fpm_pm_min_spare_servers = 5
  $fpm_pm_max_spare_servers = 35
  $fpm_pm_max_requests = 500
  $fpm_listen_backlog = 8192
  $fpm_tmp_dir = ''

  $php_post_max_size = '2G'
  $php_upload_max_filesize = '2G'
  $php_date_timezone = 'Australia/Adelaide'
  $php_max_input_vars = 20000
  $php_opcache_enabled = true
  $php_opcache_enable_cli = 1
  $php_opcache_memory_consumption = 256
  $php_opcache_max_accelerated_files = 20000
  $php_opcache_validate_timestamps = 0
  $php_tideways_enabled = true
  $php_xdebug_enabled = false

  # nginx config
  $nginx_server_tokens = 'off'
  $nginx_worker_processes = 1
  $nginx_worker_connections = 1024
  $nginx_worker_rlimit_nofile = 1024
  $nginx_fastcgi_connect_timeout = '60s'
  $nginx_fastcgi_read_timeout = '180s'
  $nginx_fastcgi_send_timeout = '60s'
  $nginx_set_real_ip_from = []
  $nginx_debug_clientmap = []
  $nginx_enable_static_cache =  false
  $nginx_cache_size = '1G'
  $nginx_cache_inactive = '24h'
  $nginx_cache_keysize = '10m'
  $nginx_cache_valid_200 = '60m'
  $nginx_ssl_enable = false
  $nginx_ssl_cert_expiry = 3650
  $nginx_gzip_enable = false
  $nginx_gzip_types = ['text/plain', 'text/html', 'application/xml', 'application/javascript', 'text/css']
  $nginx_secret_params = ['token', 'wstoken']
  $nginx_enable_security_headers = true;
  $nginx_referrer_policy = 'same-site, strict-origin-when-cross-origin';

  # app instances
  $app_instances = {}

  # New Relic PHP Agent
  $newrelic_agent_package_ensure = 'present'
  $newrelic_agent_package_list = [
    'newrelic-php5', 'newrelic-php5-common', 'newrelic-daemon',
  ]

  # New Relic Server monitor: ** deprecated 01/05/2018 **
  $newrelic_sysmond_package_ensure = 'absent'
  $newrelic_sysmond_package_list = [
    'newrelic-sysmond',
  ]
  $newrelic_sysmond_svc_name = 'newrelic-sysmond'
  $newrelic_sysmond_svc_ensure = 'stopped'

  # New Relic Infrastructure agent.
  $newrelic_infra_package_ensure = 'present'
  $newrelic_infra_package_list = [
    'newrelic-infra',
  ]
  $newrelic_infra_svc_name = 'newrelic-infra'
  $newrelic_infra_svc_ensure = 'running'

  $postfix_recipient_map = ''
  $postfix_block_unmapped_recipients = true

  # tideways
  $tideways_ensure = 'present'

  # proxy
  $wwwproxyhost = ''
  $wwwproxyport = ''

  # deployment
  $deployuser = 'mdl-deploy'
  $deploygroup = 'mdl-deploy'

  $autoinstall = false
  $autoupgrade = false

  # vsts deployment / upgrade agents
  $vsts_agent_enabled = false

  ###Example###
  # $vsts_agent_instances = {
  #   'deploy' => {
  #      agentpool      => 'OnPremise - Linux',
  #      deployqueue    => 'OnPremise - Linux',
  #      authtoken      => 'cpeadmsqzyj5stvgoeeydhpiy4zcx3vkg4ylq6hu6be3cgu36s3a',
  #   }
  # }
  ### End Example ###

  $vsts_agent_instances = {
  }

  # cache tool phar (versions > 3.2.1 are only supported by PHP 7.1+)
  $cachetool_version = '7.1.0'

  #Enable CIFS Mounts for DSP
  $dsp_cifs_enable = false
  $dsp_cifs_domain = 'uninet'
  $dsp_cifs_user = ''
  $dsp_cifs_pwd = ''
  $dsp_cifs_cred_path = '/root/dsp_cifs_cred'
}
