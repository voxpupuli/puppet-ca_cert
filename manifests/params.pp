# Private class
class ca_cert::params {
  case $::osfamily {
    'Debian': {
      $trusted_cert_dir  = '/usr/local/share/ca-certificates'
      $update_cmd        = 'update-ca-certificates'
      $cert_dir_group    = 'staff'
      $ca_file_extension = 'crt'
      $package_name      = 'ca-certificates'
    }
    'RedHat': {
      $trusted_cert_dir    = '/etc/pki/ca-trust/source/anchors'
      $distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
      $update_cmd          = 'update-ca-trust extract'
      $cert_dir_group      = 'root'
      $ca_file_extension   = 'crt'
      $package_name        = 'ca-certificates'
    }
    'Archlinux': {
      $trusted_cert_dir    = '/etc/ca-certificates/trust-source/anchors/'
      $distrusted_cert_dir = '/etc/ca-certificates/trust-source/blacklist'
      $update_cmd          = 'trust extract-compat'
      $cert_dir_group      = 'root'
      $ca_file_extension   = 'crt'
      $package_name        = 'ca-certificates'
    }
    'Suse': {
      if $::operatingsystemmajrelease =~ /(10|11)/  {
        $trusted_cert_dir  = '/etc/ssl/certs'
        $update_cmd        = 'c_rehash'
        $ca_file_extension = 'pem'
        $package_name      = 'openssl-certs'
      }
      elsif $::operatingsystemmajrelease >= '12' {
        $trusted_cert_dir    = '/etc/pki/trust/anchors'
        $distrusted_cert_dir = '/etc/pki/trust/blacklist'
        $update_cmd          = 'update-ca-certificates'
        $ca_file_extension   = 'crt'
        $package_name        = 'ca-certificates'
      }
      $cert_dir_group        = 'root'
    }
    default: {
      fail("Unsupported osfamily (${::osfamily})")
    }
  }
}
