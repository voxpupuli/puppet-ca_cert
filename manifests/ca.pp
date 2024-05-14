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
# [*checksum*]
#   The checksum of the file. (defaults to undef)
# [*checksum_type*]
#   The type of file checksum. (defauts to undef)
# [*ca_file_group*]
#   The installed CA certificate's POSIX group permissions. This uses
#   the same syntax as Puppet's native file resource's "group" parameter.
#   (defaults to 'root' with the exeption of AIX which defaults to 'system')
# [*ca_file_mode*]
#   The installed CA certificate's POSIX filesystem permissions. This uses
#   the same syntax as Puppet's native file resource's "mode" parameter.
#   (defaults to '0444', i.e. world-readable)
#
# === Examples
#
# ca_cert::ca { 'globalsign_org_intermediate':
#   source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
# }
define ca_cert::ca (
  Optional[String] $ca_text      = undef,
  String $source                 = 'text',
  String $ensure                 = 'trusted',
  Boolean $verify_https_cert     = true,
  Optional[String] $checksum     = undef,
  Optional[String[1]] $checksum_type = undef,
  Optional[String] $ca_file_group = undef,
  Optional[String] $ca_file_mode = undef,
) {
  include ca_cert
  include ca_cert::params

  if $ca_file_group == undef {
    $file_group = $ca_cert::params::ca_file_group
  } else {
    $file_group = $ca_file_group
  }

  if $ca_file_mode == undef {
    $file_mode = $ca_cert::params::ca_file_mode
  } else {
    $file_mode = $ca_file_mode
  }

  if ($ensure == 'trusted' or $ensure == 'distrusted') and $source == 'text' and !$ca_text {
    fail('ca_text is required if source is set to text')
  }

  # Since Debian/Suse based OSes don't have explicit distrust directories
  # Logic is Similar for Debian/SLES10/SLES11 - but breaking into if/elsif
  # for clarity's sake as we need to change untrusted to absent and warn in the log
  if $facts['os']['family'] == 'Debian' and $ensure == 'distrusted' {
    warning("Cannot explicitly set CA distrust on ${facts['os']['name']}.")
    warning("Ensuring that ${name} CA is absent from the trusted list.")
    $adjusted_ensure = 'absent'
  }
  elsif ($facts['os']['family'] == 'Suse' and $facts['os']['release']['major'] =~ /(10|11)/) and $ensure == 'distrusted' {
    warning("Cannot explicitly set CA distrust on ${facts['os']['name']} ${facts['os']['release']['major']}.")
    warning("Ensuring that ${name} CA is absent from the trusted list.")
    $adjusted_ensure = 'absent'
  }
  else {
    $adjusted_ensure = $ensure
  }
  # Determine Full Resource Name
  # Sles 10/11 Only Supports .pem files
  # Other supported OS variants default to .crt
  if ($facts['os']['family'] == 'Suse') and ($facts['os']['release']['major'] =~ /(10|11)/) {
    if $source != 'text' and $source !~ /^.*\.pem$/ {
      fail("${source} not proper format - SLES 10/11 CA Files must be in .pem format")
    }
  }

  # Determine Full Resource Name
  $resource_name = "${name}.${ca_cert::params::ca_file_extension}"

  $ca_cert = $adjusted_ensure ? {
    'distrusted' => "${ca_cert::params::distrusted_cert_dir}/${resource_name}",
    default      => "${ca_cert::params::trusted_cert_dir}/${resource_name}",
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
            group  => $file_group,
            mode   => $file_mode,
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
            group  => $file_group,
            mode   => $file_mode,
            notify => Exec['ca_cert_update'],
          }
        }
        'text': {
          file { $resource_name:
            ensure  => 'file',
            content => $ca_text,
            path    => $ca_cert,
            owner   => 'root',
            group   => $file_group,
            mode    => $file_mode,
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
