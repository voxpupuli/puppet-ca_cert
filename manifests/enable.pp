# Private class
class ca_cert::enable {

  include ::ca_cert::params

  if ($::osfamily == 'RedHat' and versioncmp($::operatingsystemrelease, '7') < 0) {
    if $ca_cert::force_enable {
      exec { 'enable_ca_trust':
        command   => 'update-ca-trust force-enable',
        logoutput => 'on_failure',
        path      => ['/usr/sbin', '/usr/bin', '/bin'],
        onlyif    => 'update-ca-trust check | grep DISABLED',
      }
    }
    else {
      exec { 'enable_ca_trust':
        command   => 'update-ca-trust enable',
        logoutput => 'on_failure',
        path      => ['/usr/sbin', '/usr/bin', '/bin'],
        onlyif    => 'update-ca-trust check | grep DISABLED',
      }
    }
  }

}
