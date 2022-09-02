Changelog
=========

## Unreleased
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.3.1...HEAD)


## [v2.3.2](https://github.com/pcfens/puppet-ca_cert/tree/v2.3.2)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.3.1...v2.3.2)

- Fix dependency setting [\#70](https://github.com/pcfens/puppet-ca_cert/pull/70)


## [v2.3.1](https://github.com/pcfens/puppet-ca_cert/tree/v2.3.1)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.3.0...v2.3.1)

- Update stdlib dependency [\#68](https://github.com/pcfens/puppet-ca_cert/pull/68)


## [v2.3.0](https://github.com/pcfens/puppet-ca_cert/tree/v2.3.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.2.0...v2.3.0)

- Make better use of `package_ensure` [\#63](https://github.com/pcfens/puppet-ca_cert/pull/63)
- Deleting a CA updates the list [\#65](https://github.com/pcfens/puppet-ca_cert/pull/65)


## [v2.2.0](https://github.com/pcfens/puppet-ca_cert/tree/v2.2.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.1.5...v2.2.0)

- Allow `package_ensure` to be set to latest [\#62](https://github.com/pcfens/puppet-ca_cert/pull/62)

## [v2.1.5](https://github.com/pcfens/puppet-ca_cert/tree/v2.1.5)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.1.4...v2.1.5)

- Remove dependency on deprecated string check [\#59](https://github.com/pcfens/puppet-ca_cert/pull/59)

## [v2.1.4](https://github.com/pcfens/puppet-ca_cert/tree/v2.1.4)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.1.3...v2.1.4)

- Upgrade PDK
- Note support for puppetlabs/stdlib <= 7.0


## [v2.1.3](https://github.com/pcfens/puppet-ca_cert/tree/v2.1.3)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.1.2...v2.1.3)

- Fix dependency issue with dropping certificate [\#55](https://github.com/pcfens/puppet-ca_cert/pull/55)

## [v2.1.2](https://github.com/pcfens/puppet-ca_cert/tree/v2.1.2)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.1.1...v2.1.2)

- Fix an accidental dependency cycle [\#50](https://github.com/pcfens/puppet-ca_cert/issues/50)


## [v2.1.1](https://github.com/pcfens/puppet-ca_cert/tree/v2.1.1)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.1.0...v2.1.1)

- Fix the package dependency when `install_package` is set to false [\#47](https://github.com/pcfens/puppet-ca_cert/issues/47)
- Update the stdlib dependency constraint. [\#48](https://github.com/pcfens/puppet-ca_cert/pull/48)


## [v2.1.0](https://github.com/pcfens/puppet-ca_cert/tree/v2.1.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.0.0...v2.1.0)

- Enable vs. force-enable for RHEL versions 6 and older [\#45](https://github.com/pcfens/puppet-ca_cert/pull/45)


## [v2.0.0](https://github.com/pcfens/puppet-ca_cert/tree/v2.0.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v1.8.0...v2.0.0)

This release has potentially breaking changes

- Move type validation from validate_type to Puppet  data types (removes support for Puppet 3) [\#42](https://github.com/pcfens/puppet-ca_cert/pull/42)


## [v1.8.0](https://github.com/pcfens/puppet-ca_cert/tree/v1.8.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v1.7.1...v1.8.0)

- Don't run enable_ca_trust on RHEL7 [\#37](https://github.com/pcfens/puppet-ca_cert/pull/40)


## [v1.7.1](https://github.com/pcfens/puppet-ca_cert/tree/v1.7.1)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v1.7.0...v1.7.1)

- Set better default folder permissions [\#37](https://github.com/pcfens/puppet-ca_cert/pull/37)


## [v1.7.0](https://github.com/pcfens/puppet-ca_cert/tree/v1.7.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v1.6.1...v1.7.0)

- CA File modes passed as parameters [\#33](https://github.com/pcfens/puppet-ca_cert/pull/33)
- Use remote_file instead of exec with curl/wget [\#32](https://github.com/pcfens/puppet-ca_cert/pull/32)
- Don't purge managed CAs [\#30](https://github.com/pcfens/puppet-ca_cert/pull/30)


## [v1.6.1](https://github.com/pcfens/puppet-ca_cert/tree/v1.6.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v1.6.0...v1.6.1)

- Handle URLs with special characters [\#24](https://github.com/pcfens/puppet-ca_cert/pull/24)
- Prevent wget from creating empty files when wget fails [\#25](https://github.com/pcfens/puppet-ca_cert/issues/25)

## [v1.6.0](https://github.com/pcfens/puppet-ca_cert/tree/v1.6.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v1.5.1...v1.6.0)

- Add SLES10 support (exodusftw) [\#22](https://github.com/pcfens/puppet-ca_cert/pull/22)
