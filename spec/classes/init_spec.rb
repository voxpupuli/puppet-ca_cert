require 'spec_helper'

describe 'ca_cert', type: :class do
  on_supported_os.sort.each do |os, facts|
    # define os specific defaults
    case facts[:os]['family']
    when 'Debian'
      trusted_cert_dir = '/usr/local/share/ca-certificates'
      cert_dir_group   = 'staff'
      if facts[:os]['name'] == 'Debian'
        cert_dir_mode = '2665'
      end
    when 'RedHat'
      trusted_cert_dir = '/etc/pki/ca-trust/source/anchors'
    when 'Archlinux'
      trusted_cert_dir = '/etc/ca-certificates/trust-source/anchors/'
    when 'Suse'
      if %r{(10|11)}.match?(facts[:os]['release']['major'])
        trusted_cert_dir = '/etc/ssl/certs'
        package_name     = 'openssl-certs'
      else
        trusted_cert_dir = '/etc/pki/trust/anchors'
      end
    when 'AIX'
      trusted_cert_dir = '/var/ssl/certs'
      cert_dir_group   = 'system'
    when 'Solaris'
      trusted_cert_dir = '/etc/certs/CA/'
      cert_dir_group   = 'sys'
    end

    cert_dir_group = 'root' if cert_dir_group.nil?
    cert_dir_mode  = '0755' if cert_dir_mode.nil?
    package_name   = 'ca-certificates' if package_name.nil?

    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('ca_cert::params') }
      it { is_expected.to contain_class('ca_cert::update') }
      it { is_expected.to contain_class('ca_cert::enable') } # only here to reach 100% resource coverage, sourced by ca_cert::update

      it do
        is_expected.to contain_file('trusted_certs').only_with(
          {
            'ensure'  => 'directory',
            'path'    => trusted_cert_dir,
            'owner'   => 'root',
            'group'   => cert_dir_group,
            'mode'    => cert_dir_mode,
            'purge'   => false,
            'recurse' => false,
            'notify'  => 'Exec[ca_cert_update]',
          },
        )
      end

      it do
        is_expected.to contain_package(package_name).only_with(
          {
            'ensure' => 'installed',
            'before' => ['Ca_cert::Ca[ca1]', 'Ca_cert::Ca[ca2]'],
          },
        )
      end

      it { is_expected.to contain_ca_cert__ca('ca1') } # from ./spec/fixtures/hiera
      it { is_expected.to contain_ca_cert__ca('ca2') } # from ./spec/fixtures/hiera

      if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)} || facts[:os]['family'] == 'Solaris'
        it { is_expected.to contain_file('ca1.pem') } # only here to reach 100% resource coverage
        it { is_expected.to contain_file('ca2.pem') } # only here to reach 100% resource coverage
      else
        it { is_expected.to contain_file('ca1.crt') } # only here to reach 100% resource coverage
        it { is_expected.to contain_file('ca2.crt') } # only here to reach 100% resource coverage
      end
    end
  end

  describe 'parameters on supported OS' do
    # The following tests are OS independent, so we only test one supported OS.
    # RedHat 6 was choosen as $force_enable will have functionality with it.
    redhat = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['6'],
        },
      ],
    }

    on_supported_os(redhat).each do |_os, facts|
      let(:facts) { facts }

      context 'with always_update_certs set to valid true' do
        let(:params) { { always_update_certs: true } }

        it { is_expected.to contain_exec('ca_cert_update').with_refreshonly(false) } # from ca_cert::update
      end

      context 'with purge_unmanaged_CAs set to valid true' do
        let(:params) { { purge_unmanaged_CAs: true } }

        it { is_expected.to contain_file('trusted_certs').with_purge(true) }
        it { is_expected.to contain_file('trusted_certs').with_recurse(true) }
      end

      context 'with install_package set to valid false' do
        let(:params) { { install_package: false } }

        it { is_expected.not_to contain_package('ca-certificates') }
        it { is_expected.to have_package_resource_count(0) }
      end

      context 'with force_enable set to valid true' do
        let(:params) { { force_enable: true } }

        it { is_expected.to contain_exec('enable_ca_trust').with_command('update-ca-trust force-enable') } # from ca_cert::enable
      end

      context 'with ca_certs set to valid hash' do
        let(:params) { { ca_certs: { 'testing' => { 'source' => 'puppet:///modules/ca_cert/testing.pem' } } } }

        it { is_expected.to contain_ca_cert__ca('testing').with_source('puppet:///modules/ca_cert/testing.pem') }
        it { is_expected.to contain_file('testing.crt') } # only here to reach 100% resource coverage
      end

      context 'with package_ensure set to valid value' do
        let(:params) { { package_ensure: 'absent' } }

        it { is_expected.to contain_package('ca-certificates').with_ensure('absent') }
      end

      context 'with package_name set to valid value' do
        let(:params) { { package_name: 'testing' } }

        it { is_expected.to contain_package('testing') }
      end
    end
  end
end
