# Private class
class ca_cert::update {
  require ca_cert
  require ca_cert::enable

  exec { 'ca_cert_update':
    command     => $ca_cert::params::update_cmd,
    logoutput   => 'on_failure',
    refreshonly => true,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }
}
