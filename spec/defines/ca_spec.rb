require 'spec_helper'

describe 'ca_cert::ca', type: :define do
  let(:title) { 'Globalsign_Org_Intermediate' }
  let(:pre_condition) { 'class {"ca_cert": }' }

  on_supported_os.sort.each do |os, facts|
    # define os specific defaults
    case facts[:os]['family']
    when 'Debian'
      trusted_cert_dir    = '/usr/local/share/ca-certificates'
    when 'RedHat'
      trusted_cert_dir    = '/etc/pki/ca-trust/source/anchors'
      distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
    when 'Archlinux'
      trusted_cert_dir    = '/etc/ca-certificates/trust-source/anchors/'
      distrusted_cert_dir = '/etc/ca-certificates/trust-source/blacklist'
    when 'Suse'
      trusted_cert_dir    = '/etc/pki/trust/anchors'
      distrusted_cert_dir = '/etc/pki/trust/blacklist'
    end

    ca_file_extension   = 'crt' if ca_file_extension.nil?
    ca_file_group       = 'root' if ca_file_group.nil?
    ca_file_mode        = '0644' if ca_file_mode.nil?
    distrusted_cert_dir = '' if distrusted_cert_dir.nil?

    describe "on #{os}" do
      let(:facts) { facts }

      context 'with default values for parameters' do
        it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{ca_text is required if source is set to text}) }
      end

      context 'with ca_text set to valid value' do
        let(:params) { { ca_text: 'testing' } }

        it { is_expected.to compile }

        it { is_expected.to contain_ca_cert__ca('ca1') }
        it { is_expected.to contain_ca_cert__ca('ca2') }
        it { is_expected.to contain_exec('ca_cert_update') }
        it { is_expected.to contain_file('trusted_certs') }
        it { is_expected.to contain_file('ca1.crt') }
        it { is_expected.to contain_file('ca2.crt') }
        it { is_expected.to contain_package('ca-certificates') }

        it do
          is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure'  => 'file',
              'content' => 'testing',
              'path'    => "#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      context 'with source set to valid string "puppet:///testing.crt"' do
        let(:params) { { source: 'puppet:///testing.crt' } }

        it do
          is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure' => 'file',
              'source' => 'puppet:///testing.crt',
              'path' => "#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
              'owner' => 'root',
              'group' => ca_file_group,
              'mode' => ca_file_mode,
              'notify' => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      context 'with source set to valid string "puppet:///testing.pem"' do
        let(:params) { { source: 'puppet:///testing.pem' } }

        it do
          is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure' => 'file',
              'source' => 'puppet:///testing.pem',
              'path' => "#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
              'owner' => 'root',
              'group' => ca_file_group,
              'mode' => ca_file_mode,
              'notify' => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      %w[ftp https http].each do |protocol|
        context "with source set to valid string \"#{protocol}://testing.crt\"" do
          let(:params) { { source: "#{protocol}://testing.crt" } }

          it do
            is_expected.to contain_archive("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
              {
                'ensure'         => 'present',
                'source'         => "#{protocol}://testing.crt",
                'checksum'       => nil,
                'checksum_type'  => nil,
                'allow_insecure' => false,
                'notify'         => 'Exec[ca_cert_update]',
              }
            )
          end
        end

        context "with source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { source: "#{protocol}://testing.pem" } }

          it do
            is_expected.to contain_archive("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
              {
                'ensure'         => 'present',
                'source'         => "#{protocol}://testing.pem",
                'checksum'       => nil,
                'checksum_type'  => nil,
                'allow_insecure' => false,
                'notify'         => 'Exec[ca_cert_update]',
              }
            )
          end
        end
      end

      context 'with source set to valid string "file:/testing.crt"' do
        let(:params) { { source: 'file:/testing.crt' } }

        it do
          is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure' => 'file',
              'source' => '/testing.crt',
              'path' => "#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
              'owner' => 'root',
              'group' => ca_file_group,
              'mode' => ca_file_mode,
              'notify' => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      context 'with source set to valid string "file:/testing.pem"' do
        let(:params) { { source: 'file:/testing.pem' } }

        it do
          is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure' => 'file',
              'source' => '/testing.pem',
              'path' => "#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
              'owner' => 'root',
              'group' => ca_file_group,
              'mode' => ca_file_mode,
              'notify' => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      context 'with ensure set to valid string "present"' do
        let(:params) { { ensure: 'present' } }

        it do
          is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure'  => 'file',
              'content' => nil,
              'path'    => "#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      context 'with ensure set to valid string "distrusted"' do
        let(:params) { { ensure: 'distrusted' } }

        it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{ca_text is required if source is set to text}) }
      end

      context 'with ensure set to valid string "distrusted" when source is "file:/dummy.pem"' do
        let(:params) { { ensure: 'distrusted', source: 'file:/dummy.pem' } }

        if facts[:os]['family'] == 'Debian'
          it do
            is_expected.to contain_file("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
              {
                'ensure' => 'absent',
                'notify' => 'Exec[ca_cert_update]',
              }
            )
          end
        else
          it do
            is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
              {
                'ensure' => 'file',
                'source' => '/dummy.pem',
                'path' => "#{distrusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
                'owner' => 'root',
                'group' => ca_file_group,
                'mode' => ca_file_mode,
                'notify' => 'Exec[ca_cert_update]',
              }
            )
          end
        end
      end

      context 'with ensure set to valid string "distrusted" when ca_text is "testing"' do
        let(:params) { { ensure: 'distrusted', ca_text: 'testing' } }

        if facts[:os]['family'] == 'Debian'
          it do
            is_expected.to contain_file("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
              {
                'ensure' => 'absent',
                'notify' => 'Exec[ca_cert_update]',
              }
            )
          end
        else
          it do
            is_expected.to contain_file("Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
              {
                'ensure'  => 'file',
                'content' => 'testing',
                'path'    => "#{distrusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}",
                'owner'   => 'root',
                'group'   => ca_file_group,
                'mode'    => ca_file_mode,
                'notify'  => 'Exec[ca_cert_update]',
              }
            )
          end
        end
      end

      context 'with ensure set to valid string "absent"' do
        let(:params) { { ensure: 'absent' } }

        it do
          is_expected.to contain_file("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").only_with(
            {
              'ensure' => 'absent',
              'notify' => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      %w[ftp https http].each do |protocol|
        context "with verify_https_cert set to valid false when source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { verify_https_cert: false, source: "#{protocol}://testing.pem" } }

          it { is_expected.to contain_archive("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").with_allow_insecure(true) }
        end

        context "with checksum set to valid value when source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { checksum: 'testing', source: "#{protocol}://testing.pem" } }

          it { is_expected.to contain_archive("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").with_checksum('testing') }
        end

        context "with checksum_type set to valid value when source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { checksum_type: 'testing', source: "#{protocol}://testing.pem" } }

          it { is_expected.to contain_archive("#{trusted_cert_dir}/Globalsign_Org_Intermediate.#{ca_file_extension}").with_checksum_type('testing') }
        end
      end
    end
  end
end
