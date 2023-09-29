# instance defaults
class lmsweb::defaults
{
  # service configuration
  $root_dir = undef
  $www_port = '80'
  $pkgname = undef
  $pkgensure = 'absent'
  $pkgsync = true
  $autoinstall = false
  $autoupgrade = false
  $dirtarget = undef

  # socket
  $fpm_enable_unix_socket = true
  $fpm_tcp_port = 9000

  # fpm
  $mdl_post_max_size = '2G'
  $mdl_upload_max_filesize = '2G'

  # database
  $dbhost = 'localhost'
  $dbname = 'moodle'
  $dbuser = 'moodleuser'
  $dbpass = 'moodleuser'
  $dbprefix = 'mdl_'
  $environment = 'LOCAL'

  # storage
  $data_mount_ensure = 'absent'
  $data_mount_dev = ''
  $data_mount_dev_ml = ''
  $data_mount_dev_cw = ''
  $data_mount_opts = ''
  $data_mount_type = ''
  $data_mount_directory_name = 'moodledata'

  # log
  $log_mount_ensure = 'absent'
  $log_mount_dev = ''
  $log_mount_dev_ml = ''
  $log_mount_dev_cw = ''
  $log_mount_opts = ''
  $log_mount_type = ''
  $log_prefix_log_name = false
  $log_owner = 'root'
  $log_group = 'root'
  $log_mode  = '0644'

  # build
  $build_mount_ensure = 'absent'
  $build_mount_dev = ''
  $build_mount_dev_ml = ''
  $build_mount_dev_cw = ''
  $build_mount_opts = ''
  $build_mount_type = ''

  # DocServicesPrinting mount
  $dsp_mount_ensure = 'absent'
  $dsp_mount_dev = ''
  $dsp_mount_type = ''
  $dsp_mount_opts = ''

  # util
  $utilhostname = ''
  $admincronenabled = true
  $admincronminute = '*'
  $backupcronenabled = false
  $backupcronweekday = '*'
  $backupcronhour = '21'
  $backupcronminute = '0'
  $croncheckactivedc = true
  $customphpcliopts = '-d newrelic.distributed_tracing_enabled=0'
  $trashdircronenabled = true
  $trashdirexpirydays = '190'
  $trashdircronhour = '5'
  $trashdircronminute = '15'
  $trashdirusleep = '500000'

  # application
  $debugdisplay = 0
  $debug = 'E_ALL | E_STRICT'
  $noemailever = 1
  $enableunittest = 0
  $enablebehattest = 0
  $sslproxy = false
  $https = false
  $enablealtcompcache = true
  $sessionhandler = ''
  $sessionredishost = ''
  $sessionredisport = 6379
  $sessionredisdatabase = 0
  $sessionredisacquiretimeout = 120
  $sessionredislockexpire = 60
  $sessionredismaxlockswaiting = 20
  $sessionredissentinelhosts = '[]'
  $sessionredissentinelmastergroup = ''
  $sentinelenablehostcache = true
  $ssokey = ''
  $secretkey = ''
  $ssorequesttimeout = -30
  $resultentryurl = ''
  $resultentrykey = ''
  $ssosecretkey = ''
  $debugusers = ''
  $instancename = ''
  $libssokey = ''
  $assignsecretkey = ''
  $lrsssokey = ''
  $twofactorenckey = ''
  $twofactorlocaltoken = ''
  $turnitintooltwoaccountid = ''
  $turnitintooltwosecretkey = ''
  $backupdestination = ''

  # application - mahara
  $passwordsaltmain = ''
  $searchplugin = 'internal'
  $emailcontact = 'ists.helpdesk@unisa.edu.au'
  $noreplyaddress = 'noreply@unisa.edu.au'
  $dblogerror = true
  $urlsecret = 'LTSAdmin'
  $skins = true
  $productionmode = false
  $pathtoclam = '/usr/bin/clamscan'
  $usersuniquebyusername = true

  # application - Lime
  $sessionhandle = 'application.core.web.DbHttpSession'

  # newrelic
  $newrelic_collector_ignore_exceptions = ''
  $newrelic_collector_ignore_errors = ''
  $newrelic_collector_ignore_user_exception_handler = 'no'
  $newrelic_tracer_threshold = 'apdex_f'
  $newrelic_tracer_stack_trace_threshold = '500ms'
  $newrelic_tracer_record_sql = 'obfuscated'
  $newrelic_attributes_enabled = true
  $newrelic_attributes_exclude = 'request.parameters.token, request.parameters.wstoken'
  $newrelic_attributes_include = 'request.parameters.*'
  $newrelic_distributed_tracing_enabled = false

  # error page config.
  $error_400_title = 'Page or resource not available'
  $error_400_heading = 'Page or resource not available!'
  $error_400_content = 'The page or resource requested is not available as it does not exist or you do not have permission to access it.'
  $error_400_note = undef
  $error_400_show_home_btn = true
  $error_400_show_status_btn = false
  $error_500_title = 'Something went wrong'
  $error_500_heading = 'Something went wrong!'
  $error_500_content = 'An unexpected error has occurred, please try again later.'
  $error_500_note = undef
  $error_500_show_home_btn = true
  $error_500_show_status_btn = true
}
