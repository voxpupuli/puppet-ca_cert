# @summary
#   Manage a user defined CA Certificate on a system.
#   On OSes that support distrusting pre-installed CAs this can be managed as well.
#
# @example
#   ca_cert::ca { 'globalsign_org_intermediate':
#     source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
#   }
#
# @param ca_text
#   The text of the CA certificate to install. Required if text is the source
#   (default). If a different source is specified this parameter is ignored.
#
# @param source
#   Where the CA certificate should be retrieved from. text, http, https, ftp,
#   file, and puppet protocols/sources are supported. If text, then the ca_text parameter
#   is also required. Defaults to text.
#
# @param ensure
#   Whether or not the CA certificate should be on a system or not. Valid
#   values are trusted, present, distrusted, and absent. Note: untrusted is
#   not supported on Debian based systems - using it will log a warning
#   and treat it the same as absent. (defaults to trusted)
#
# @param verify_https_cert
#   When retrieving a certificate whether or not to validate the CA of the
#   source. (defaults to true)
#
# @param checksum
#   The checksum of the file. (defaults to undef)
#
# @param checksum_type
#   The type of file checksum. (defauts to undef)
#
define ca_cert::ca (
  Enum['present', 'trusted', 'distrusted', 'absent'] $ensure = 'trusted',
  String $source = 'text',
  Boolean $verify_https_cert = true,
  Optional[String] $ca_text = undef,
  Optional[String] $checksum = undef,
  Optional[String[1]] $checksum_type = undef,
) {
  include ca_cert

  if ($ensure == 'trusted' or $ensure == 'distrusted') and $source == 'text' and !$ca_text {
    fail('ca_text is required if source is set to text')
  }

  # Since Debian based OSes don't have explicit distrust directories
  if $facts['os']['family'] == 'Debian' and $ensure == 'distrusted' {
    warning("Cannot explicitly set CA distrust on ${facts['os']['name']}.")
    warning("Ensuring that ${name} CA is absent from the trusted list.")
    $adjusted_ensure = 'absent'
  }
  else {
    $adjusted_ensure = $ensure
  }

  # Determine Full Resource Name
  $resource_name = "${name}.${ca_cert::ca_file_extension}"

  $ca_cert = $adjusted_ensure ? {
    'distrusted' => "${ca_cert::distrusted_cert_dir}/${resource_name}",
    default      => "${ca_cert::trusted_cert_dir}/${resource_name}",
  }

  case $adjusted_ensure {
    'present', 'trusted', 'distrusted': {
      $source_array = split($source, ':')
      $protocol_type = $source_array[0]
      case $protocol_type {
        'puppet': {
          file { $resource_name:
            ensure => 'file',
            source => $source,
            path   => $ca_cert,
            owner  => 'root',
            group  => $ca_cert::ca_file_group,
            mode   => $ca_cert::ca_file_mode,
            notify => Exec['ca_cert_update'],
          }
        }
        'ftp', 'https', 'http': {
          archive { $ca_cert:
            ensure         => 'present',
            source         => $source,
            checksum       => $checksum,
            checksum_type  => $checksum_type,
            allow_insecure => !$verify_https_cert,
            notify         => Exec['ca_cert_update'],
          }
        }
        'file': {
          $source_path = $source_array[1]
          file { $resource_name:
            ensure => 'file',
            source => $source_path,
            path   => $ca_cert,
            owner  => 'root',
            group  => $ca_cert::ca_file_group,
            mode   => $ca_cert::ca_file_mode,
            notify => Exec['ca_cert_update'],
          }
        }
        'text': {
          file { $resource_name:
            ensure  => 'file',
            content => $ca_text,
            path    => $ca_cert,
            owner   => 'root',
            group   => $ca_cert::ca_file_group,
            mode    => $ca_cert::ca_file_mode,
            notify  => Exec['ca_cert_update'],
          }
        }
        default: {
          fail('Protocol must be puppet, file, http, https, ftp, or text.')
        }
      }
    }
    'absent': {
      file { $ca_cert:
        ensure => absent,
        notify => Exec['ca_cert_update'],
      }
    }
    default: {
      fail("Ca_cert::Ca[${name}] - ensure must be set to present, trusted, distrusted, or absent.")
    }
  }
}
