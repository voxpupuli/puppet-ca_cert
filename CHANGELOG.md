# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.0.0](https://github.com/voxpupuli/puppet-ca_cert/tree/v4.0.0) (2025-10-07)

[Full Changelog](https://github.com/voxpupuli/puppet-ca_cert/compare/v3.1.0...v4.0.0)

**Breaking changes:**

- Drop puppet, update openvox minimum version to 8.19 [\#130](https://github.com/voxpupuli/puppet-ca_cert/pull/130) ([TheMeier](https://github.com/TheMeier))

**Implemented enhancements:**

- puppet/archive Allow 8.x [\#129](https://github.com/voxpupuli/puppet-ca_cert/pull/129) ([TheMeier](https://github.com/TheMeier))

## [v3.1.0](https://github.com/voxpupuli/puppet-ca_cert/tree/v3.1.0) (2024-06-25)

[Full Changelog](https://github.com/voxpupuli/puppet-ca_cert/compare/v3.0.0...v3.1.0)

**Implemented enhancements:**

- replace create\_resources\(\) with iterator [\#115](https://github.com/voxpupuli/puppet-ca_cert/pull/115) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- puppet-lint: validate parameter types&docs [\#114](https://github.com/voxpupuli/puppet-ca_cert/pull/114) ([bastelfreak](https://github.com/bastelfreak))
- cleanup spec tests & facterdb\_string\_keys: switch to strings [\#113](https://github.com/voxpupuli/puppet-ca_cert/pull/113) ([bastelfreak](https://github.com/bastelfreak))

## [v3.0.0](https://github.com/voxpupuli/puppet-ca_cert/tree/v3.0.0) (2024-06-07)

[Full Changelog](https://github.com/voxpupuli/puppet-ca_cert/compare/v2.5.0...v3.0.0)

**Breaking changes:**

- Support distrusting ca's on Debian; Changed ca\_cert::ca parameter names and meaning [\#107](https://github.com/voxpupuli/puppet-ca_cert/pull/107) ([h-haaks](https://github.com/h-haaks))
- Remove defaults for AIX and Solaris as we can't verify/maintain these [\#100](https://github.com/voxpupuli/puppet-ca_cert/pull/100) ([h-haaks](https://github.com/h-haaks))
- Move and use params only in ca\_certs class [\#99](https://github.com/voxpupuli/puppet-ca_cert/pull/99) ([h-haaks](https://github.com/h-haaks))
- Drop EoL Suse support [\#97](https://github.com/voxpupuli/puppet-ca_cert/pull/97) ([h-haaks](https://github.com/h-haaks))
- Drop support for EoL Ubuntu versions [\#88](https://github.com/voxpupuli/puppet-ca_cert/pull/88) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL EL support [\#87](https://github.com/voxpupuli/puppet-ca_cert/pull/87) ([bastelfreak](https://github.com/bastelfreak))
- Drop Puppet 4/5/6 support [\#86](https://github.com/voxpupuli/puppet-ca_cert/pull/86) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Support proxy when downloading remote certificates [\#108](https://github.com/voxpupuli/puppet-ca_cert/pull/108) ([h-haaks](https://github.com/h-haaks))
- Add SLES and OpenSUSE 15 support [\#104](https://github.com/voxpupuli/puppet-ca_cert/pull/104) ([h-haaks](https://github.com/h-haaks))
- Add supported OSes [\#94](https://github.com/voxpupuli/puppet-ca_cert/pull/94) ([h-haaks](https://github.com/h-haaks))
- Add RedHat 9, CentOS, Rocky and AlmaLinux support [\#93](https://github.com/voxpupuli/puppet-ca_cert/pull/93) ([h-haaks](https://github.com/h-haaks))
- enable acceptance tests [\#89](https://github.com/voxpupuli/puppet-ca_cert/pull/89) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- Cleanup before release [\#109](https://github.com/voxpupuli/puppet-ca_cert/pull/109) ([h-haaks](https://github.com/h-haaks))
- Refactor ca\_cert:ca unit tests to use on\_supported\_os [\#105](https://github.com/voxpupuli/puppet-ca_cert/pull/105) ([h-haaks](https://github.com/h-haaks))
- Move OS specific data from params.pp into hiera [\#102](https://github.com/voxpupuli/puppet-ca_cert/pull/102) ([h-haaks](https://github.com/h-haaks))
- Cleanup Debian defaults [\#101](https://github.com/voxpupuli/puppet-ca_cert/pull/101) ([h-haaks](https://github.com/h-haaks))
- Remove ca\_cert::update class [\#98](https://github.com/voxpupuli/puppet-ca_cert/pull/98) ([h-haaks](https://github.com/h-haaks))
- Remove ca\_cert::force\_enable param; Remove ca\_cert::enable class [\#95](https://github.com/voxpupuli/puppet-ca_cert/pull/95) ([h-haaks](https://github.com/h-haaks))
- Remove PDK refs from metadata [\#92](https://github.com/voxpupuli/puppet-ca_cert/pull/92) ([h-haaks](https://github.com/h-haaks))
- Remove litmus [\#91](https://github.com/voxpupuli/puppet-ca_cert/pull/91) ([h-haaks](https://github.com/h-haaks))

# Changelog

## [v2.5.0](https://github.com/pcfens/puppet-ca_cert/tree/v2.5.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.4.0...v2.5.0)

- Add support for Kali Linux [\#82](https://github.com/pcfens/puppet-ca_cert/pull/82)
- Switch to namespaced functions for stdlib [\#83](https://github.com/pcfens/puppet-ca_cert/pull/83)
- Improve testing capabilities [\#79](https://github.com/pcfens/puppet-ca_cert/pull/79), [\#84](https://github.com/pcfens/puppet-ca_cert/pull/84)

## [v2.4.0](https://github.com/pcfens/puppet-ca_cert/tree/v2.4.0)
[Full Changelog](https://github.com/pcfens/puppet-ca_cert/compare/v2.3.2...v2.4.0)

- Support Puppet 8 by replacing references to legacy facts [\#75](https://github.com/pcfens/puppet-ca_cert/pull/75)
- Add support for RHEL8 [\#73](https://github.com/pcfens/puppet-ca_cert/pull/73)
- Add support for Solaris 11 [\#72](https://github.com/pcfens/puppet-ca_cert/pull/72)
- Add support for AIX [\#71](https://github.com/pcfens/puppet-ca_cert/pull/71)
- Use puppet/archive instead of remote_file [\#69](https://github.com/pcfens/puppet-ca_cert/pull/69)

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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
