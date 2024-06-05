# @summary
#   Manage a CA Certificate in the the shared system-wide truststore.
#
# @example
#   ca_cert::ca { 'globalsign_org_intermediate':
#     source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
#   }
#
# @param ensure
#   Whether or not the CA certificate should be on a system or not.
#   - `present`/`absent` is used to manage local/none default CAs.
#   - `trusted`/`distrusted` is used to manage system CAs.
#
# @param content
#   PEM formatted certificate content
#   This attribute is mutually exclusive with `source`
#
# @param source
#   A source certificate, which will be copied into place on the local system.
#   This attribute is mutually exclusive with `content`
#   Uri support, see puppet-archive.
#
# @param allow_insecure_source
#   Wether to allow insecure download or not.
#
# @param checksum
#   The checksum of the file. (defaults to undef)
#
# @param checksum_type
#   The type of file checksum. (defauts to undef)
#
define ca_cert::ca (
  Enum['present', 'absent', 'trusted', 'distrusted'] $ensure = 'present',
  Boolean $allow_insecure_source = false,
  Optional[String[1]] $source = undef,
  Optional[String[1]] $content = undef,
  Optional[String[1]] $checksum = undef,
  Optional[String[1]] $checksum_type = undef,
) {
  include ca_cert

  # Determine Full Resource Name
  $resource_name = "${name}.${ca_cert::ca_file_extension}"

  case $ensure {
    'present', 'absent': {
      $ca_cert = "${ca_cert::trusted_cert_dir}/${resource_name}"
    }
    'trusted', 'distrusted': {
      $ca_cert = "${ca_cert::distrusted_cert_dir}/${resource_name}"
    }
    default: {}
  }

  # On Debian we trust/distrust Os provided CAs in config
  if $facts['os']['family'] == 'Debian' and member(['trusted', 'distrusted'], $ensure) {
    if $ensure == 'trusted' {
      exec { "trust ca ${resource_name}":
        command => "sed -ri \'s|!(.*)${resource_name}|\\1${resource_name}|\' ${ca_cert::ca_certificates_conf}",
        onlyif  => "grep -q ${resource_name} ${ca_cert::ca_certificates_conf} && grep -q \'^!.*${resource_name}\' ${ca_cert::ca_certificates_conf}",
        path    => ['/bin','/usr/bin'],
        notify  => Exec['ca_cert_update'],
      }
    } else {
      exec { "distrust ca ${resource_name}":
        command => "sed -ri \'s|(.*)${resource_name}|!\\1${resource_name}|\' ${ca_cert::ca_certificates_conf}",
        onlyif  => "grep -q ${resource_name} ${ca_cert::ca_certificates_conf} && grep -q \'^[^!].*${resource_name}\' ${ca_cert::ca_certificates_conf}",
        path    => ['/bin','/usr/bin'],
        notify  => Exec['ca_cert_update'],
      }
    }
  }
  else {
    case $ensure {
      'present', 'distrusted': {
        if $source {
          archive { $ca_cert:
            ensure         => 'present',
            source         => $source,
            checksum       => $checksum,
            checksum_type  => $checksum_type,
            allow_insecure => $allow_insecure_source,
            notify         => Exec['ca_cert_update'],
          }
          -> file { $ca_cert:
            ensure => 'file',
            owner  => 'root',
            group  => $ca_cert::ca_file_group,
            mode   => $ca_cert::ca_file_mode,
            notify => Exec['ca_cert_update'],
          }
        } elsif $content {
          file { $ca_cert:
            ensure  => 'file',
            content => $content,
            owner   => 'root',
            group   => $ca_cert::ca_file_group,
            mode    => $ca_cert::ca_file_mode,
            notify  => Exec['ca_cert_update'],
          }
        } else {
          fail('Either `source` or `content` is required')
        }
      }
      'absent', 'trusted': {
        file { $ca_cert:
          ensure => absent,
          notify => Exec['ca_cert_update'],
        }
      }
      default: {}
    }
  }
}
