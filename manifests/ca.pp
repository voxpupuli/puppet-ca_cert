# ca.pp
#
# Manage a CA Certificate on a system. This cannot manage pre-installed
# operating system CAs.
#
# === Parameters
#
# [*ca_text*]
#   The text of the CA certificate to install. Required if text is the source
#   (default). If a different source is specified this parameter is ignored.
# [*source*]
#   Where the CA certificate should be retrieved from. text, http, https, ftp,
#   file, and puppet protocols/sources are supported. If text, then the ca_text parameter
#   is also required. Defaults to text.
# [*ensure*]
#   Whether or not the CA certificate should be on a system or not. Valid
#   values are trusted, present, distrusted, and absent. Note: untrusted is
#   not supported on Debian based systems - using it will log a warning
#   and treat it the same as absent. (defaults to trusted)
# [*verify_https_cert*]
#   When retrieving a certificate whether or not to validate the CA of the
#   source. (defaults to true)
#
# === Examples
#
# ca_cert::ca { 'globalsign_org_intermediate':
#   source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
# }

define ca_cert::ca (
  $ca_text           = undef,
  $source            = 'text',
  $ensure            = 'trusted',
  $verify_https_cert = true,
) {

  include ca_cert::params
  include ca_cert::update

  validate_string($source)
  validate_bool($verify_https_cert)

  if ($ensure == 'trusted' or $ensure == 'disrusted') and $source == 'text' and $ca_text == undef {
    fail('ca_text is required if source is set to text')
  }

  # Since Debian based OSes don't have explicit distrust directories
  # we need to change untrusted to absent and put a warning in the log.
  if $::osfamily == 'Debian' and $ensure == 'distrusted' {
    warning("Cannot explicitly set CA distrust on ${::operatingsystem}.")
    warning("Ensuring that ${name} CA is absent from the trusted list.")
    $adjusted_ensure = 'absent'
  } else {
    $adjusted_ensure = $ensure
  }

  $ca_cert = $adjusted_ensure ? {
    'distrusted' => "${ca_cert::params::distrusted_cert_dir}/${name}.crt",
    default      => "${ca_cert::params::trusted_cert_dir}/${name}.crt",
  }

  case $adjusted_ensure {
    present, trusted, distrusted: {
      $sourceArray = split($source, ':')
      $protocol_type = $sourceArray[0]
      case $protocol_type {
        puppet: {
          file { "${name}.crt":
            ensure => present,
            source => $source,
            path   => $ca_cert,
            owner  => 'root',
            group  => 'root',
            notify => Exec['ca_cert_update'],
          }
        }
        ftp, https, http: {
          $verify_https = $verify_https_cert ? {
            true  => '',
            false => '--no-check-certificate',
          }
          exec { "get_${name}.crt":
            command =>
              "wget ${verify_https} -O ${ca_cert} ${source} 2> /dev/null",
            path    => ['/usr/bin', '/bin'],
            creates => $ca_cert,
            notify  => Exec['ca_cert_update'],
          }
        }
        file: {
          $source_path = $sourceArray[1]
          file { "${name}.crt":
            ensure => present,
            source => $source_path,
            path   => $ca_cert,
            owner  => 'root',
            group  => 'root',
            notify => Exec['ca_cert_update'],
          }
        }
        text: {
          file { "${name}.crt":
            ensure  => present,
            content => $ca_text,
            path    => $ca_cert,
            owner   => 'root',
            group   => 'root',
            notify  => Exec['ca_cert_update'],
          }
        }
        default: {
          fail('Protocol must be puppet, file, http, https, ftp, or text.')
        }
      }
    }
    absent: {
      file { $ca_cert:
        ensure => absent,
      }
    }
  }

  anchor { "ca_cert::ca::${name}":
    require => Class['ca_cert::update'],
  }

}
