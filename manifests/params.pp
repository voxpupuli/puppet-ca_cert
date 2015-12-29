# Private class
class ca_cert::params {
  case $::osfamily {
    'debian': {
      $trusted_cert_dir = '/usr/local/share/ca-certificates'
      $update_cmd       = 'update-ca-certificates'
      $cert_dir_group   = 'staff'
      $ca_package       = 'ca-certificates'
      $cert_extension   = 'crt'
    }
    'redhat': {
      case $::operatingsystemmajrelease {
        '5':  {
          $trusted_cert_dir    = '/etc/pki/tls/certs'
          $distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
          $update_cmd          = 'c_rehash'
          $cert_dir_group      = 'root'
          $ca_package          = 'openssl-perl'
          $cert_extension      = 'pem'
          }
        default: {
          $trusted_cert_dir    = '/etc/pki/ca-trust/source/anchors'
          $distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
          $update_cmd          = 'update-ca-trust extract'
          $cert_dir_group      = 'root'
          $ca_package          = 'ca-certificates'
          $cert_extension      = 'pem'
          }
      }
    }
    default: {
      fail("Unsupported osfamily (${::osfamily})")
    }
  }
}
