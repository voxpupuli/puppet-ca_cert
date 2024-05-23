# == Class: ca_cert
#
# This module manages the user installed certificate authority (CA)
# certificates installed on the server. It does not manage operating
# system defaults CA certificates.
#
# === Parameters
#
# [*package_name*]
#   The name of the package(s) to be installed
#
# [*update_cmd*]
#   Command to be used to update CA certificates.
#
# [*trusted_cert_dir*]
#   Absolute directory path to the folder containing trusted certificates.
#
# [*distrusted_cert_dir*]
#   Absolute directory path to the folder containing distrusted certificates (OS dependent).
#
# [*cert_dir_group*]
#   The installed trusted certificate's POSIX group permissions. This uses
#   the same syntax as Puppet's native file resource's "group" parameter.
#   It defaults to 'system' on AIX, to 'sys' on Solaris, to 'staff' on
#   Ubuntu/Debian, and to 'root' in other cases.
#
# [*cert_dir_mode*]
#   The installed  trusted certificate's POSIX filesystem permissions. This uses
#   the same syntax as Puppet's native file resource's "mode" parameter.
#   It defaults to '2665' on Debian, and to '0755' on other cases.
#
# [*ca_file_group*]
#   The installed CA certificate's POSIX group permissions. This uses
#   the same syntax as Puppet's native file resource's "group" parameter.
#   (defaults to 'root' with the exeption of AIX which defaults to 'system')
#
# [*ca_file_mode*]
#   The installed CA certificate's POSIX filesystem permissions. This uses
#   the same syntax as Puppet's native file resource's "mode" parameter.
#   (defaults to '0444', i.e. world-readable)
#
# [*ca_file_extension*]
#   File extenstion for the certificate.
#
# [*package_ensure*]
#   The ensure parameter to pass to the package resource
#
# [*always_update_certs*]
#   Run the appropriate update CA certificates command for your operating
#   system on every Puppet run whether it is needed or not.
#
# [*purge_unmanaged_CAs*]
#   When set to true (default: false), user installed CA
#   certificates (in the appropriate directories) not managed by this
#   module will be purged.
#
# [*install_package*]
#   Whether or not this module should install the ca_certificates package.
#   The package contains the system default (typically Mozilla) CA
#   certificates, as well as the tools required for managing other installed
#   CA certificates.
#
# [*ca_certs*]
#   A hash of CA certificates that should be installed as part of the class
#   declaration
#
# === Examples
#
# class { 'ca_cert': }
#
# class { 'ca_cert':
#   manage_all_user_CAs => true,
# }
#
# === Authors
#
# Phil Fenstermacher <phillip.fenstermacher@gmail.com>
#
class ca_cert (
  String[1] $package_name = $ca_cert::params::package_name,
  String[1] $update_cmd = $ca_cert::params::update_cmd,
  String[1] $trusted_cert_dir = $ca_cert::params::trusted_cert_dir,
  Optional[String[1]] $distrusted_cert_dir = $ca_cert::params::distrusted_cert_dir,
  String[1] $cert_dir_group = $ca_cert::params::cert_dir_group,
  String[1] $ca_file_group = $ca_cert::params::ca_file_group,
  String[1] $cert_dir_mode = $ca_cert::params::cert_dir_mode,
  String[1] $ca_file_mode = $ca_cert::params::ca_file_mode,
  String[1] $ca_file_extension = $ca_cert::params::ca_file_extension,
  String[1] $package_ensure = 'installed',
  Boolean $always_update_certs = false,
  Boolean $purge_unmanaged_CAs = false, # lint:ignore:variable_contains_upcase lint:ignore:variable_is_lowercase
  Boolean $install_package = true,
  Hash    $ca_certs = {},
) inherits ca_cert::params {
  file { 'trusted_certs':
    ensure  => directory,
    path    => $trusted_cert_dir,
    owner   => 'root',
    group   => $cert_dir_group,
    mode    => $cert_dir_mode,
    purge   => $purge_unmanaged_CAs, # lint:ignore:variable_contains_upcase lint:ignore:variable_is_lowercase
    recurse => $purge_unmanaged_CAs, # lint:ignore:variable_contains_upcase lint:ignore:variable_is_lowercase
    notify  => Exec['ca_cert_update'],
  }

  if $install_package {
    stdlib::ensure_packages($package_name, { ensure => $package_ensure })

    if $package_ensure != 'absent' {
      Package[$package_name] -> Ca_cert::Ca <| |>
    }
  }

  if !empty($ca_certs) {
    create_resources('ca_cert::ca', $ca_certs)
  }

  exec { 'ca_cert_update':
    command     => $update_cmd,
    logoutput   => 'on_failure',
    refreshonly => !$always_update_certs,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }
}
