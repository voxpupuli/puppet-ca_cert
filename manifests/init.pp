# @summary
#   This module manages the user installed certificate authority (CA)
#   certificates installed on the server. It does not manage operating
#   system defaults CA certificates.
#
# @example Basic usage
#   class { 'ca_cert': }
#
#   class { 'ca_cert':
#     manage_all_user_CAs => true,
#   }
#
# @author
#   Phil Fenstermacher <phillip.fenstermacher@gmail.com>
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
# @param install_package
#   Whether or not this module should install the ca_certificates package.
#   The package contains the system default (typically Mozilla) CA
#   certificates, as well as the tools required for managing other installed
#   CA certificates.
#
# @param force_enable
#   Use the force-enable option on RH 7 and earlier (and derivatives)
# @param ca_certs
#   A hash of CA certificates that should be installed as part of the class
#   declaration.
#
# @param package_ensure
#   The ensure parameter to pass to the package resource.
#
# @param package_name
#   The name of the package(s) to be installed.
#
# @param trusted_cert_dir
#   Absolute directory path to the folder containing trusted certificates.
#
# @param distrusted_cert_dir
#   Absolute directory path to the folder containing distrusted certificates.
#
# @param update_cmd
#   Command to be used to update CA certificates.
#
# @param cert_dir_group
#   The installed trusted certificate's POSIX group permissions. This uses
#   the same syntax as Puppet's native file resource's "group" parameter.
#   It defaults to 'system' on AIX, to 'sys' on Solaris, to 'staff' on
#   Ubuntu/Debian, and to 'root' in other cases.
#
# @param cert_dir_mode
#   The installed  trusted certificate's POSIX filesystem permissions. This uses
#   the same syntax as Puppet's native file resource's "mode" parameter.
#   It defaults to '2665' on Debian, and to '0755' on other cases.
#
# @param supported
#   Boolean to ensure module runs only on supported OS families and versions.
#
class ca_cert (
  Boolean $always_update_certs             = false,
  Boolean $purge_unmanaged_CAs             = false, # lint:ignore:variable_is_lowercase lint:ignore:variable_contains_upcase
  Boolean $install_package                 = true,
  Boolean $force_enable                    = false,
  Hash    $ca_certs                        = {},
  String  $package_ensure                  = 'installed',
  String[1] $package_name                  = 'ca-certificates',
  String[1] $trusted_cert_dir              = '/etc/pki/ca-trust/source/anchors',
  Optional[String[1]] $distrusted_cert_dir = undef,
  String[1] $update_cmd                    = 'update-ca-trust extract',
  String[1] $cert_dir_group                = 'root',
  String[1] $cert_dir_mode                 = '0755',
  Boolean $supported                       = false,
) {
  if $supported == false {
    fail("Unsupported osfamily (${facts['os']['family']}) or unsupported version (${facts['os']['release']['major']})")
  }

  file { 'trusted_certs':
    ensure  => directory,
    path    => $trusted_cert_dir,
    owner   => 'root',
    group   => $cert_dir_group,
    mode    => $cert_dir_mode,
    purge   => $purge_unmanaged_CAs, # lint:ignore:variable_is_lowercase lint:ignore:variable_contains_upcase
    recurse => $purge_unmanaged_CAs, # lint:ignore:variable_is_lowercase lint:ignore:variable_contains_upcase
    notify  => Exec['ca_cert_update'],
  }

  if $install_package {
    ensure_packages($package_name, { ensure => $package_ensure })

    if $package_ensure != 'absent' {
      Package[$package_name] -> Ca_cert::Ca <| |>
    }
  }

  create_resources('ca_cert::ca', $ca_certs)

  if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['full'], '7') < 0 {
    $_enable_command = $force_enable ? {
      true    => 'update-ca-trust force-enable',
      default => 'update-ca-trust enable',
    }

    exec { 'enable_ca_trust':
      command   => $_enable_command,
      logoutput => 'on_failure',
      path      => ['/usr/sbin', '/usr/bin', '/bin'],
      onlyif    => 'update-ca-trust check | grep DISABLED',
    }
  }

  exec { 'ca_cert_update':
    command     => $update_cmd,
    logoutput   => 'on_failure',
    refreshonly => !$always_update_certs,
    path        => ['/usr/sbin', '/usr/bin', '/bin'],
  }
}
