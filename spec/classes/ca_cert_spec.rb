require 'spec_helper'

describe 'ca_cert', type: :class do
  on_supported_os.each do |os, facts|
    case facts[:os]['family']
    when 'Debian'
      trusted_cert_dir = '/usr/local/share/ca-certificates'
    when 'RedHat'
      trusted_cert_dir = '/etc/pki/ca-trust/source/anchors'
      update_cmd       = 'update-ca-trust extract'
    when 'Archlinux'
      trusted_cert_dir = '/etc/ca-certificates/trust-source/anchors/'
      update_cmd       = 'trust extract-compat'
    when 'Suse'
      trusted_cert_dir = '/etc/pki/trust/anchors'
      update_cmd       = 'update-ca-certificates'
    end

    cert_dir_group = 'root' if cert_dir_group.nil?
    cert_dir_mode  = '0755' if cert_dir_mode.nil?
    update_cmd     = 'update-ca-certificates' if update_cmd.nil?
    package_name   = 'ca-certificates' if package_name.nil?

    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('ca_cert::params') }

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
          }
        )
      end

      it do
        is_expected.to contain_package(package_name).only_with(
          {
            'ensure' => 'installed',
            'before' => ['Ca_cert::Ca[ca1]', 'Ca_cert::Ca[ca2]'],
          }
        )
      end

      it do
        is_expected.to contain_exec('ca_cert_update').only_with(
          {
            'command'     => update_cmd,
            'logoutput'   => 'on_failure',
            'refreshonly' => true,
            'path'        => ['/usr/sbin', '/usr/bin', '/bin'],
          }
        )
      end

      it { is_expected.to contain_ca_cert__ca('ca1') } # from ./spec/fixtures/hiera
      it { is_expected.to contain_ca_cert__ca('ca2') } # from ./spec/fixtures/hiera
      it { is_expected.to contain_file('ca1.crt').with_source('puppet:///modules/ca_cert/ca1.pem') }
      it { is_expected.to contain_file('ca2.crt').with_source('puppet:///modules/ca_cert/ca2.pem') }

      context 'with always_update_certs set to true' do
        let(:params) { { always_update_certs: true } }

        it { is_expected.to contain_exec('ca_cert_update').with_refreshonly(false) }
      end

      context 'with purge_unmanaged_CAs set to true' do
        let(:params) { { purge_unmanaged_CAs: true } }

        it { is_expected.to contain_file('trusted_certs').with_purge(true) }
        it { is_expected.to contain_file('trusted_certs').with_recurse(true) }
      end

      context 'with install_package set to false' do
        let(:params) { { install_package: false } }

        it { is_expected.not_to contain_package(package_name) }
        it { is_expected.to have_package_resource_count(0) }
      end

      context 'with package_ensure set to absent' do
        let(:params) { { package_ensure: 'absent' } }

        it { is_expected.to contain_package(package_name).with_ensure('absent') }
      end

      context 'with package_name set to testing' do
        let(:params) { { package_name: 'testing' } }

        it { is_expected.to contain_package('testing') }
      end
    end
  end
end
