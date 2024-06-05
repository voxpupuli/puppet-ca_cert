# ca_cert puppet module

[![Build Status](https://github.com/voxpupuli/puppet-ca_cert/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-ca_cert/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-ca_cert/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-ca_cert/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/ca_cert.svg)](https://forge.puppetlabs.com/puppet/ca_cert)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/ca_cert.svg)](https://forge.puppetlabs.com/puppet/ca_cert)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/ca_cert.svg)](https://forge.puppetlabs.com/puppet/ca_cert)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/ca_cert.svg)](https://forge.puppetlabs.com/puppet/ca_cert)
[![License](https://img.shields.io/github/license/voxpupuli/puppet-ca_cert.svg)](https://github.com/voxpupuli/puppet-ca_cert/blob/master/LICENSE)

#### Table of Contents

1. [Description - What does the module do?](#description)
2. [Setup - The basics of getting started with mongodb](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

The ca_cert module tries to provide a simple way to manage Certificate Authority (CA)
certificates on a Linux system.

## Usage

On supported OSes custom and OS default CAs can be managed by using the defined type [ca_cert::ca](manifests/ca.pp).
The [ca_cert](manifests/init.pp) class could be realized to costomize how this module manages the certificates.

### Install a custom CA

```puppet
ca_cert::ca { 'myorg_ca':
  source => 'https://ca.myorg.com/myorg_ca.pem',
}
```

### Manage custom CAs with hiera

```yaml
---
ca_cert::ca_certs:
  'myorg_ca':
    source: 'https://ca.myorg.com/myorg_ca.pem'
```
```puppet
include ca_cert
```

### Distrust a OS default CA

Distrusting OS default CAs is handled differently by different OS families.
On Debian/Ubuntu like OSes that support distrusting by using a configuration file
the certificate content is not needed.
Simply use

```puppet
ca_cert::ca { 'DigiCert_Global_Root_G3':
  ensure => 'distrusted',
}
```

On RedHat like OSes that use a folder to manage distrusted default CAs, the certificate
source or content has to be provided as well

```puppet
ca_cert::ca { 'DigiCert_Global_Root_G3':
  ensure => 'distrusted',
  source => 'https://cacerts.digicert.com/DigiCertGlobalRootG3.crt.pem',
}
```

### Ensuring only puppet managed custom CAs are present

```puppet

class { 'ca_cert':
  purge_unmanaged_CAs => true,
  ca_certs            => {
    ....
  }
}
```

## Limitations

This module has been tested on operating systems in [metadata.json](metadata.json)

## Development

This module is maintained by [Vox Pupuli](https://voxpupuli.org/). Voxpupuli
welcomes new contributions to this module, especially those that include
documentation and rspec tests. We are happy to provide guidance if necessary.

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for more details.
