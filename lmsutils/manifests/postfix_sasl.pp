# Class: lmsutils
# ===========================
class lmsutils::postfix_sasl(
  Boolean $enabled = true,
  String $postfix_sasl_pass_file = '/etc/postfix/sasl_passwd',
  String $sudo_user = 'mdl-deploy',
  String $script_path = '/usr/local/bin/postfix_sasl_mv.sh',
  String $sudoers_filename = '142_postfix_sasl_pass'
)
{

  if($enabled) {
    $file_ensure = 'file'
  } else {
    $file_ensure = 'absent'
  }


  file { $script_path:
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('lmsutils/postfix_sasl_mv.sh.epp')
  }

  file { "/etc/sudoers.d/${sudoers_filename}":
    ensure  => $file_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp('lmsutils/142_postfix_sasl_pass.epp')
  }
}
