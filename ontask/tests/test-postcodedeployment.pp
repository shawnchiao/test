# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
class { 'ontask':
            server_name               => 'test.ontask-uo.unisa.edu.au',
            www_ontask_service_enable => true,
            nodejs_environment        => 'test',
            www_ontask_service_ensure => 'running',
            newrelic_licence_key      => 'e89c9177649b82b1a00edac1734760ebd16c4916',
            newrelic_app_name         => 'Ontask-Web-[TEST]'

  }
