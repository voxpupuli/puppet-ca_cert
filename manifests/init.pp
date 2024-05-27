# @summary
#   This module manages the user defined certificate authority (CA)
#   certificates on the server. On OSes that support a distrusted
#   folder the module also manages distrusting system default CA certificates.
#
# @example Basic usage
#   class { 'ca_cert': }
#
# @example Purge unmanaged user CAs
#   class { 'ca_cert':
#     purge_unmanaged_CAs => true,
#   }
#
# @example Custom certificates handling
#   class { 'ca_cert':
#     update_cmd        => '/usr/bin/c_rehash',
#     trusted_cert_dir  => '/var/ssl/certs,
#     cert_dir_group    => 'system',
#     cert_dir_mode     => '0755',
#     ca_file_group     => 'system',
#     ca_file_mode      => '0644',
#     ca_file_extension => 'pem',
#   }
#
# @param update_cmd
#   Command to be used to update CA certificates.
#   Default provided by Hiera for supported Operating Systems.
#
# @param trusted_cert_dir
#   Absolute directory path to the folder containing trusted certificates.
#   Default provided by Hiera for supported Operating Systems.
#
# @param distrusted_cert_dir
#   Absolute directory path to the folder containing distrusted certificates.
#   Default provided by Hiera for supported Operating Systems.
#
# @param install_package
#   Whether or not this module should install the ca_certificates package.
#   The package contains the system default (typically Mozilla) CA
#   certificates, as well as the tools required for managing other installed
#   CA certificates.
#
# @param package_ensure
#   The ensure parameter to pass to the package resource.
#
# @param package_name
#   The name of the package(s) to be installed.
#
# @param cert_dir_group
#   The installed trusted certificate's POSIX group permissions. This uses
#   the same syntax as Puppet's native file resource's "group" parameter.
#
# @param cert_dir_mode
#   The installed  trusted certificate's POSIX filesystem permissions. This uses
#   the same syntax as Puppet's native file resource's "mode" parameter.
#
# @param ca_file_group
#   The installed CA certificate's POSIX group permissions. This uses
#   the same syntax as Puppet's native file resource's "group" parameter.
#
# @param ca_file_mode
#   The installed CA certificate's POSIX filesystem permissions. This uses
#   the same syntax as Puppet's native file resource's "mode" parameter.
#
# @param ca_file_extension
#   File extenstion for the certificate.
#
# @param always_update_certs
#   Run the appropriate update CA certificates command for your operating
#   system on every Puppet run whether it is needed or not.
#
# @param purge_unmanaged_CAs
#   When set to true (default: false), user installed CA
#   certificates (in the appropriate directories) not managed by this
#   module will be purged.
#
# @param ca_certs
#   A hash of CA certificates that should be installed as part of the class
#   declaration.
#
class ca_cert (
  String[1] $update_cmd,
  Stdlib::Absolutepath $trusted_cert_dir,
  Optional[Stdlib::Absolutepath] $distrusted_cert_dir = undef,
  Boolean $install_package = true,
  Stdlib::Ensure::Package $package_ensure = 'installed',
  String[1] $package_name = 'ca-certificates',
  String[1] $cert_dir_group = 'root',
  Stdlib::Filemode $cert_dir_mode = '0755',
  String[1] $ca_file_group = 'root',
  Stdlib::Filemode $ca_file_mode = '0644',
  String[1] $ca_file_extension = 'crt',
  Boolean $always_update_certs = false,
  Boolean $purge_unmanaged_CAs = false, # lint:ignore:variable_contains_upcase lint:ignore:variable_is_lowercase
  Hash    $ca_certs = {},
) {
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
