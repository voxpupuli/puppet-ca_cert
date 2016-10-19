ca_cert
=======

[![Build Status](https://travis-ci.org/pcfens/puppet-ca_cert.png?branch=master)](https://travis-ci.org/pcfens/puppet-ca_cert)

Overview
--------

The ca_cert module tries to provide a simple way to manage Certificate Authority (CA)
certificates on a Linux system. (Patches are welcome to help support other
operating sytems)

Usage
-----

After the `ca_cert` module has been declared add CA certificates with the ca_cert::ca
definition.

### ca_cert

`ca_cert` ensures that the locations and tools needed to manage the CAs are present on
your system.

Optional parameters:
  * `always_update_certs`: Run your system's update CA command even when there are no
                           updates needed. (defaults to false)
  * `purge_unmanaged_CAs`: Purge non-OS default CAs from the system. This will only
                           remove CAs that might be installed using your OS's default
                           management method. (defaults to false)
  * `install_package`: Whether or not this module should install the ca_certificates
                       package. The package contains the default trusted (typically
                       Mozilla) CA certificates, as well as the tools required for this
                       module to manage other installed CA certificates. (defaults to true)
  * `ca_certs`: A hash of certificates you would like added. These may also be defined
                by declaring `ca_cert::ca` once for each certificate.

### ca_cert::ca

CAs can be added as URLs, text, or a puppet managed file

```puppet
ca_cert::ca { 'GlobalSign-OrgSSL-Intermediate':
  ensure => 'trusted',
  source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
}
```

```puppet
ca_cert::ca { 'GlobalSign-OrgSSL-Intermediate':
  ensure => 'trusted',
  source => 'puppet:///modules/profiles/CAs/InCommon.crt',
}
```


`ca_cert::ca`:

  * `ca_text`: The text of the CA certificate to install. Required if text is the source
               (default). If a different source is specified this parameter is ignored.
  * `source`: Where the CA certificate should be retrieved from. text, http, https, ftp,
              file, and puppet protocols/sources are supported. If text, then the ca_text parameter
              is also required. Defaults to text.

              **Warning**: certificates delivered via http, https, or ftp won't be
              updated if the upstream source changes.

              **SLES 11 Specific Detail**: Cert File must be in `.pem` format

  * `ensure`: Whether or not the CA certificate should be on the system or not. Valid
              values are trusted, present, distrusted, and absent. Trusted is the same
              as present. On Debian systems untrusted is the same as absent. On RedHat
              based systems untrusted certificates are placed in a different path before
              calling the update command. (defaults to trusted)
  * `verify_https_cert`: If a certificate is retrieved over HTTPS, whether or not the
                         server's certificate should be validated against the fetching
                         machine's trusted CA list or not. (defaults to true)

Supported Platforms
-------------------

This module has been tested on Ubuntu 14.04, Ubuntu 12.04, CentOS 6, SLES 11, SLES 12, OpenSuSE 13.1, OpenSuSE 13.2 and OpenSuSE 42.1 Leap.
