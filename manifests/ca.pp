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

  include ::ca_cert::params
  include ::ca_cert::update

  validate_string($source)
  validate_bool($verify_https_cert)

  if ($ensure == 'trusted' or $ensure == 'distrusted') and $source == 'text' and !is_string($ca_text) {
    fail('ca_text is required if source is set to text')
  }

  # Since Debian/Suse based OSes don't have explicit distrust directories
  # Logic is Similar for Debian/SLES10/SLES11 - but breaking into if/elsif
  # for clarity's sake as we need to change untrusted to absent and warn in the log
  if $::osfamily == 'Debian' and $ensure == 'distrusted' {
    warning("Cannot explicitly set CA distrust on ${::operatingsystem}.")
    warning("Ensuring that ${name} CA is absent from the trusted list.")
    $adjusted_ensure = 'absent'
  }
  elsif ($::osfamily == 'Suse' and $::operatingsystemmajrelease =~ /(10|11)/) and $ensure == 'distrusted' {
    warning("Cannot explicitly set CA distrust on ${::operatingsystem} ${::operatingsystemmajrelease}.")
    warning("Ensuring that ${name} CA is absent from the trusted list.")
    $adjusted_ensure = 'absent'
  }
  else {
    $adjusted_ensure = $ensure
  }
  # Determine Full Resource Name
  # Sles 10/11 Only Supports .pem files
  # Other supported OS variants default to .crt
  if ($::osfamily == 'Suse') and ($::operatingsystemmajrelease =~ /(10|11)/) {
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
            ensure  => present,
            source  => $source,
            path    => $ca_cert,
            owner   => 'root',
            group   => 'root',
            require => Package[$ca_cert::params::package_name],
            notify  => Exec['ca_cert_update'],
          }
        }
        'ftp', 'https', 'http': {
          $verify_https = $verify_https_cert ? {
            true  => '',
            false => '--no-check-certificate',
          }
          exec { "get_${resource_name}":
            command =>
              "wget ${verify_https} -O ${ca_cert} ${source} 2> /dev/null",
            path    => ['/usr/bin', '/bin'],
            creates => $ca_cert,
            notify  => Exec['ca_cert_update'],
          }
        }
        'file': {
          $source_path = $source_array[1]
          file { $resource_name:
            ensure  => present,
            source  => $source_path,
            path    => $ca_cert,
            owner   => 'root',
            group   => 'root',
            require => Package[$ca_cert::params::package_name],
            notify  => Exec['ca_cert_update'],
          }
        }
        'text': {
          file { $resource_name:
            ensure  => present,
            content => $ca_text,
            path    => $ca_cert,
            owner   => 'root',
            group   => 'root',
            require => Package[$ca_cert::params::package_name],
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
      }
    }
    default: {
      fail("Ca_cert::Ca[${name}] - ensure must be set to present, trusted, distrusted, or absent.")
    }
  }

  anchor { "ca_cert::ca::${name}":
    require => Class['ca_cert::update'],
  }

}
