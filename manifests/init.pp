# == Class: ca_cert
#
# This module manages the user installed certificate authority (CA)
# certificates installed on the server. It does not manage operating
# system defaults CA certificates.
#
# === Parameters
#
# [*always_update_certs*]
#   Run the appropriate update CA certificates command for your operating
#   system on every Puppet run whether it is needed or not.
# [*purge_unmanaged_CAs*]
#   When set to true (default: false), user installed CA
#   certificates (in the appropriate directories) not managed by this
#   module will be purged.
# [*install_package*]
#   Whether or not this module should install the ca_certificates package.
#   The package contains the system default (typically Mozilla) CA
#   certificates, as well as the tools required for managing other installed
#   CA certificates.
# [*force_enable*]
#   Use the force-enable option on RH 7 and earlier (and derivatives)
# [*ca_certs*]
#   A hash of CA certificates that should be installed as part of the class
#   declaration
# [*package_ensure*]
#   The ensure parameter to pass to the package resource
# [*package_name*]
#   The name of the package(s) to be installed
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
# lint:ignore:variable_is_lowercase
class ca_cert (
  Boolean $always_update_certs = false,
  Boolean $purge_unmanaged_CAs = false, # lint:ignore:variable_contains_upcase
  Boolean $install_package     = true,
  Boolean $force_enable        = false,
  Hash    $ca_certs            = {},
  String  $package_ensure      = 'installed',
  String  $package_name        = $ca_cert::params::package_name,
) inherits ca_cert::params {
  include ca_cert::params
  include ca_cert::update

  if $always_update_certs == true {
    Exec <| title=='ca_cert_update' |> {
      refreshonly => false,
    }
  }

  $trusted_cert_dir = $ca_cert::params::trusted_cert_dir
  $cert_dir_group   = $ca_cert::params::cert_dir_group
  $cert_dir_mode    = $ca_cert::params::cert_dir_mode

  file { 'trusted_certs':
    ensure  => directory,
    path    => $trusted_cert_dir,
    owner   => 'root',
    group   => $cert_dir_group,
    mode    => $cert_dir_mode,
    purge   => $purge_unmanaged_CAs, # lint:ignore:variable_contains_upcase
    recurse => $purge_unmanaged_CAs, # lint:ignore:variable_contains_upcase
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
}
# lint:endignore:variable_is_lowercase
