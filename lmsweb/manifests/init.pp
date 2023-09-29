# == Class: lmsweb
#
# Configures NGINX & PHP7*-FPM for a moodle lms node.
#
# === Parameters
#
# Document parameters here.
#
# [*instance_root*]
#     Desc: Moodle rootdir (eg /moodle0)
#     Type: <string>
#     Default : "/moodle0"
#
# [*server_name*]
#     Desc: NGINX VHOST Server Name (eg lo.unisa.edu.au)
#     Type: <string>
#     Default : "localhost"
#
# [*localcache_mount_size*]
#     Desc: Size of moodle localcache tmpfs (ramdisk) filesystem.
#     Type: <string>
#     Default : "1G"
#
# [*data_mount_dev*]
#     Desc: moodledata folder mount device
#     Type: <string>
#     Default : ""
#
# [*mdl_data_mount_opt*]
#     Desc: moodledata folder mount options
#     Type: <string>
#     Default : "l"
#
# [*data_mount_opts]
#     Desc: moodledata folder mount filesystem type.
#     Type: <string>
#     Default : ""
#
# === Examples
#
#  class { 'lmsweb':
#    instance_root => "/moodle0",
#    server_name => "load.lo.unisa.edu.au",
#    localcache_mount_size => "1G",
#    data_mount_dev => "itutc-lrnstg7.cw.unisa.edu.au:lrn_nfs_next",
#    data_mount_opts => "defaults,acl,vers=4,_netdev",
#    data_mount_opts => "nfs",
#  }
#
class lmsweb (
    # service enabled
    Boolean $enabled = $lmsweb::params::enabled,

    # php version - used to build paths and service names etc (individual package versions in pkg_list, and
    # disabling and removing old versions etc must be done seperately)
    String $php_version = 'php74',
    String $php_previous_version = 'php72',
    Boolean $php_remove_previous_version = false,

    # nginx/fpm user
    String $www_user = $lmsweb::params::www_user,
    String $www_group = $lmsweb::params::www_group,

    # fpm config
    String $fpm_pm = $lmsweb::params::fpm_pm,
    Integer $fpm_pm_max_children = $lmsweb::params::fpm_pm_max_children,
    Integer $fpm_pm_start_servers = $lmsweb::params::fpm_pm_start_servers,
    Integer $fpm_pm_min_spare_servers = $lmsweb::params::fpm_pm_min_spare_servers,
    Integer $fpm_pm_max_spare_servers = $lmsweb::params::fpm_pm_max_spare_servers,
    Integer $fpm_pm_max_requests = $lmsweb::params::fpm_pm_max_requests,
    Integer $fpm_listen_backlog = $lmsweb::params::fpm_listen_backlog,
    String  $fpm_tmp_dir = $lmsweb::params::fpm_tmp_dir,

    String $php_post_max_size = $lmsweb::params::php_post_max_size,
    String $php_upload_max_filesize = $lmsweb::params::php_upload_max_filesize,
    String $php_date_timezone = $lmsweb::params::php_date_timezone,
    Integer $php_max_input_vars = $lmsweb::params::php_max_input_vars,
    Boolean $php_opcache_enabled = $lmsweb::params::php_opcache_enabled,
    Integer $php_opcache_enable_cli = $lmsweb::params::php_opcache_enable_cli,
    Integer $php_opcache_memory_consumption = $lmsweb::params::php_opcache_memory_consumption,
    Integer $php_opcache_validate_timestamps = $lmsweb::params::php_opcache_validate_timestamps,
    Boolean $php_tideways_enabled = $lmsweb::params::php_tideways_enabled,
    Boolean $php_xdebug_enabled = $lmsweb::params::php_xdebug_enabled,
    String $php_zend_exception_ignore_args = 'On',
    Integer $php_serialize_precision = -1,
    Integer $php_session_sid_length = 32,
    String $php_session_lazy_write = 'On',
    String $php_mail_add_x_header = 'Off',

    # nginx config
    String $nginx_version = 'rh-nginx118',
    String $nginx_previous_version = 'rh-nginx110',
    Boolean $nginx_remove_previous_version = false,
    String $nginx_server_tokens = $lmsweb::params::nginx_server_tokens,
    Integer $nginx_worker_processes = $lmsweb::params::nginx_worker_processes,
    Integer $nginx_worker_connections = $lmsweb::params::nginx_worker_connections,
    Integer $nginx_worker_rlimit_nofile = $lmsweb::params::nginx_worker_rlimit_nofile,
    String $nginx_fastcgi_connect_timeout = $lmsweb::params::nginx_fastcgi_connect_timeout,
    String $nginx_fastcgi_read_timeout = $lmsweb::params::nginx_fastcgi_read_timeout,
    String $nginx_fastcgi_send_timeout = $lmsweb::params::nginx_fastcgi_send_timeout,
    Array[String] $nginx_set_real_ip_from = $lmsweb::params::nginx_set_real_ip_from,
    Array[String] $nginx_debug_clientmap = $lmsweb::params::nginx_debug_clientmap,
    Boolean $nginx_enable_static_cache = $lmsweb::params::nginx_enable_static_cache,
    String $nginx_cache_path = '',
    String $nginx_cache_size = $lmsweb::params::nginx_cache_size,
    String $nginx_cache_inactive = $lmsweb::params::nginx_cache_inactive,
    String $nginx_cache_keysize = $lmsweb::params::nginx_cache_keysize,
    String $nginx_cache_valid_200 = $lmsweb::params::nginx_cache_valid_200,
    Boolean $nginx_ssl_enable = $lmsweb::params::nginx_ssl_enable,
    Boolean $nginx_gzip_enable = $lmsweb::params::nginx_gzip_enable,
    Array[String] $nginx_gzip_types = $lmsweb::params::nginx_gzip_types,
    Array[String] $nginx_secret_params = $lmsweb::params::nginx_secret_params,
    Boolean $nginx_enable_security_headers = $lmsweb::params::nginx_enable_security_headers,
    String $nginx_referrer_policy = $lmsweb::params::nginx_referrer_policy,

    #list of packages to be installed
    Array[String] $pkg_list = [
      "${php_version}-runtime",
      "${php_version}-php-cli",
      "${php_version}-php-fpm",
      "${php_version}-php-gd",
      "${php_version}-php-intl",
      "${php_version}-php-ldap",
      "${php_version}-php-mbstring",
      "${php_version}-php-opcache",
      "${php_version}-php-pdo",
      "${php_version}-php-pear",
      "${php_version}-php-json",
      "${php_version}-php-pgsql",
      "${php_version}-php-process",
      "${php_version}-php-soap",
      "${php_version}-php-xml",
      "${php_version}-php-xmlrpc",
      "${php_version}-php-common",
      "${php_version}-php-pecl-redis",
      "${php_version}-php-pecl-zip",
      "${php_version}-php-pecl-mcrypt",
      "${php_version}-php-pecl-yaml",
      "${php_version}-php-pecl-xdebug",
      $nginx_version,
      'graphviz',
      'clamav', 'clamav-update',
    ],

    #list of packages to be removed
    Array[String] $remove_php_pkg_list = [
      "${php_previous_version}-runtime",
      "${php_previous_version}-php-cli",
      "${php_previous_version}-php-fpm",
      "${php_previous_version}-php-gd",
      "${php_previous_version}-php-intl",
      "${php_previous_version}-php-ldap",
      "${php_previous_version}-php-mbstring",
      "${php_previous_version}-php-opcache",
      "${php_previous_version}-php-pdo",
      "${php_previous_version}-php-pear",
      "${php_previous_version}-php-json",
      "${php_previous_version}-php-pgsql",
      "${php_previous_version}-php-process",
      "${php_previous_version}-php-soap",
      "${php_previous_version}-php-xml",
      "${php_previous_version}-php-xmlrpc",
      "${php_previous_version}-php-common",
      "${php_previous_version}-php-pecl-redis",
      "${php_previous_version}-php-pecl-zip",
      "${php_previous_version}-php-pecl-mcrypt",
      "${php_previous_version}-php-pecl-yaml",
      "${php_previous_version}-php-pecl-xdebug",
    ],
    Array[String] $remove_nginx_pkg_list = [
      $nginx_previous_version,
      "${nginx_previous_version}-nginx",
      "${nginx_previous_version}-runtime"
    ],

    # instances - key / value hash of instances.
    # Defined as a list in the following structure:
    # name:
    #    variable: value
    # $lme_instances_base = $lmsweb::params::lme_instances_base,
    # $lme_instances = $lmsweb::params::lme_instances,
    #
    # $mdl_instances_base = $lmsweb::params::mdl_instances_base,
    # $mdl_instances = $lmsweb::params::mdl_instances,
    #
    # $mhr_instances_base = $lmsweb::params::mhr_instances_base,
    # $mhr_instances = $lmsweb::params::mhr_instances,

    Hash $app_instances = $lmsweb::params::app_instances,

    # new relic agent
    Array[String] $newrelic_agent_package_list = $lmsweb::params::newrelic_agent_package_list,
    Enum['present','absent'] $newrelic_agent_package_ensure = $lmsweb::params::newrelic_agent_package_ensure,
    Array[String] $newrelic_sysmond_package_list = $lmsweb::params::newrelic_sysmond_package_list,
    Enum['present','absent'] $newrelic_sysmond_package_ensure = $lmsweb::params::newrelic_sysmond_package_ensure,
    String $newrelic_sysmond_svc_name = $lmsweb::params::newrelic_sysmond_svc_name,
    Enum['running','stopped'] $newrelic_sysmond_svc_ensure = $lmsweb::params::newrelic_sysmond_svc_ensure,
    Array[String] $newrelic_infra_package_list = $lmsweb::params::newrelic_infra_package_list,
    Enum['present','absent'] $newrelic_infra_package_ensure = $lmsweb::params::newrelic_infra_package_ensure,
    String $newrelic_infra_svc_name = $lmsweb::params::newrelic_infra_svc_name,
    Enum['running','stopped'] $newrelic_infra_svc_ensure = $lmsweb::params::newrelic_infra_svc_ensure,
    String $newrelic_license_key = '',
    String $newrelic_api_key = '',
    String $newrelic_api_url = '',

    # tideways
    Enum['present','absent'] $tideways_ensure = $lmsweb::params::tideways_ensure,

    # postfix recipiant mapping
    String $postfix_recipient_map = $lmsweb::params::postfix_recipient_map,
    Boolean $postfix_block_unmapped_recipients = $lmsweb::params::postfix_block_unmapped_recipients,

    # proxy
    String $wwwproxyhost = $lmsweb::params::wwwproxyhost,
    String $wwwproxyport = $lmsweb::params::wwwproxyport,

    # deployment
    String $deployuser = $lmsweb::params::deployuser,
    String $deploygroup = $lmsweb::params::deploygroup,

    # Autoinstall / upgrade
    Boolean $autoinstall = $lmsweb::params::autoinstall,
    Boolean $autoupgrade = $lmsweb::params::autoupgrade,

    # VSTS agent
    Boolean $vsts_agent_enabled = $lmsweb::params::vsts_agent_enabled,
    Hash $vsts_agent_instances = $lmsweb::params::vsts_agent_instances,

    String $cachetool_version = $lmsweb::params::cachetool_version,

    #Enable CIFS Mounts for DSP
    Boolean $dsp_cifs_enable = $lmsweb::params::dsp_cifs_enable,
    Boolean $dsp_cifs_utils_remove = false,
    String $dsp_cifs_domain = $lmsweb::params::dsp_cifs_domain,
    String $dsp_cifs_user = $lmsweb::params::dsp_cifs_user,
    String $dsp_cifs_pwd = $lmsweb::params::dsp_cifs_pwd,
    String $dsp_cifs_cred_path = $lmsweb::params::dsp_cifs_cred_path,

    #Logrotate Settings
    Integer $logrotate_cron_rotate = 100,
    Integer $logrotate_php_rotate = 100,
    Integer $logrotate_nginx_rotate = 100,
    Integer $logrotate_newrelic_rotate = 30,
    Integer $logrotate_tideways_rotate = 7

) inherits lmsweb::params
{
    require lmsweb::defaults

    $nginx_install_path = "/opt/rh/${nginx_version}"
    $nginx_config_path = "/etc/opt/rh/${nginx_version}/nginx"
    $nginx_previous_svc_name = "${nginx_previous_version}-nginx"
    $nginx_svc_name = "${nginx_version}-nginx"

    if ($nginx_cache_path == '') {
        $nginx_static_cache_path = "/var${nginx_install_path}/cache/static"
    } else {
        $nginx_static_cache_path = "${nginx_cache_path}/static"
    }

    if ($wwwproxyhost != '') {
        if ($wwwproxyport != '') {
            $wwwproxyurl = "${wwwproxyhost}:${wwwproxyport}"
        } else {
            $wwwproxyurl = $wwwproxyhost
        }
    } else {
        $wwwproxyurl = ''
    }

    if ($fpm_tmp_dir == '') {
        $fpm_tmp_dir_path = '/tmp'
    } else {
        $fpm_tmp_dir_path = $fpm_tmp_dir
    }

    if($enabled) {
        $fpm_install_path = "/opt/remi/${php_version}/root"
        $fpm_config_path = "/etc/opt/remi/${php_version}"
        $fpm_previous_svc_name = "${php_previous_version}-php-fpm"
        $fpm_svc_name = "${php_version}-php-fpm"
        # extract php version components.
        $php_major = regsubst($php_version, '^php([0-9])([0-9])$', '\1')
        $php_minor = regsubst($php_version, '^php([0-9])([0-9])$', '\2')

        $pkg_ensure = 'present'
        $svc_ensure = 'running'
        $svc_enable = true
        $dir_ensure = 'directory'
        $dir_force = false
        $file_ensure = 'file'
        $file_force = false
        $mnt_ensure = 'mounted'
        $mdl_update_script_path = '/usr/bin/mdl-update'
        $activedc_script_path = '/usr/bin/activedc'
        $finddel_script_path = '/usr/local/bin/finddel'
        $php_expose_php = 'off'

        # file { ["/apps", "/logs", "/build", "/data"]:
        #   ensure => $phpwap::dir_ensure,
        #   force  => $phpwap::dir_force,
        #   owner  => $phpwap::deployuser,
        #   group  => $phpwap::deploygroup,
        #   mode   => '775'
        # } ->
        class { 'lmsweb::install': }
        -> class { 'lmsweb::config': }
        -> class { 'lmsweb::service': }
        -> class { 'lmsweb::uninstall': }
        -> class { 'lmsweb::cleanup': }

        # App instances
        create_resources(lmsweb::instance, $app_instances)

        if ($vsts_agent_enabled) {
            class { 'lmsvstsagent':
              enabled         => true,
              agent_instances => $vsts_agent_instances,
              proxyhost       => $wwwproxyhost,
              proxyport       => $wwwproxyport,
            }
        }

    } else {
        $svc_ensure = 'stopped'
        $svc_enable = false

        class { 'lmsweb::service': } #->
    }
}
