# Private class
class ca_cert::update {
  require ca_cert

  if ($facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['full'], '7') < 0) {
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

  exec { 'ca_cert_update':
    command     => $ca_cert::update_cmd,
    logoutput   => 'on_failure',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }
}
