# Private class
class ca_cert::params {
  case $::osfamily {
    'debian': {
      $trusted_cert_dir = '/usr/local/share/ca-certificates'
      $update_cmd       = 'update-ca-certificates'
      $cert_dir_group   = 'staff'
    }
    'redhat': {
      $trusted_cert_dir    = '/etc/pki/ca-trust/source/anchors'
      $distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
      $update_cmd          = 'update-ca-trust extract'
      $cert_dir_group      = 'root'
    }
    default: {
      fail("Unsupported osfamily (${::osfamily})")
    }
  }
}
