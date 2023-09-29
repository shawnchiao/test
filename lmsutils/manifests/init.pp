# Class: lmsutils
# ===========================
class lmsutils(
  Boolean $enabled = true,
  String $postfix_sasl_pass_file = '/etc/postfix/sasl_passwd',
  String $postfix_sudo_user = 'mdl-deploy'
)
{
  class { 'lmsutils::postfix_sasl':
      enabled                => $enabled,
      postfix_sasl_pass_file => $postfix_sasl_pass_file,
      sudo_user              => $postfix_sudo_user
  }
}
