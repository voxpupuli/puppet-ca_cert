# Private class
class ca_cert::update {
  include ::ca_cert::params

  if ($::osfamily == 'RedHat' and versioncmp($::operatingsystemrelease, '7') < 0) {
    if $ca_cert::force_enable {
      exec { 'enable_ca_trust':
        command   => 'update-ca-trust force-enable',
        logoutput => 'on_failure',
        path      => ['/usr/sbin', '/usr/bin', '/bin'],
        onlyif    => 'update-ca-trust check | grep DISABLED',
        before    => Exec['ca_cert_update'],
      }
    }
    else {
      exec { 'enable_ca_trust':
        command   => 'update-ca-trust enable',
        logoutput => 'on_failure',
        path      => ['/usr/sbin', '/usr/bin', '/bin'],
        onlyif    => 'update-ca-trust check | grep DISABLED',
        before    => Exec['ca_cert_update'],
      }
    }
  }

  exec { 'ca_cert_update':
    command     => $ca_cert::params::update_cmd,
    logoutput   => 'on_failure',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }
}
