require 'spec_helper'

describe 'ca_cert::ca', type: :define do
  let(:title) { 'Globalsign_Org_Intermediate' }
  let(:pre_condition) do
    'class {"ca_cert":
      ca_certs => {},
    }'
  end

  on_supported_os.sort.each do |os, facts|
    # define os specific defaults
    case facts[:os]['family']
    when 'Debian'
      trusted_cert_dir    = '/usr/local/share/ca-certificates'
    when 'RedHat'
      trusted_cert_dir    = '/etc/pki/ca-trust/source/anchors'
      distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
    when 'Archlinux'
      trusted_cert_dir    = '/etc/ca-certificates/trust-source/anchors'
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
        it { is_expected.to compile.and_raise_error(%r{Either `source` or `content` is required}) }
      end

      context 'with content set to valid value' do
        let(:params) { { content: 'testing' } }

        it { is_expected.to contain_exec('ca_cert_update') }
        it { is_expected.to contain_file('trusted_certs') }
        it { is_expected.to contain_package('ca-certificates') }

        it do
          is_expected.to contain_file("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
            {
              'ensure'  => 'file',
              'content' => 'testing',
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      {
        'puppet' => { 'hostname' => nil, 'path' => 'testing.crt' },
        'file'   => { 'hostname' => nil, 'path' => 'testing.pem' },
        'ftp'    => { 'hostname' => 'ftp.myorg.com', 'path' => 'testing.crt' },
        'http'   => { 'hostname' => 'www.myorg.com', 'path' => 'testing.pem' },
      }.each do |key, values|
        context "with source set to \"#{key}://#{values['hostname']}/#{values['path']}\"" do
          let(:params) { { source: "#{key}://#{values['hostname']}/#{values['path']}" } }

          it do
            is_expected.to contain_archive("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
              {
                'ensure'         => 'present',
                'source'         => "#{key}://#{values['hostname']}/#{values['path']}",
                'checksum'       => nil,
                'checksum_type'  => nil,
                'allow_insecure' => false,
                'before'         => ["File[#{trusted_cert_dir}/#{title}.#{ca_file_extension}]"],
                'notify'         => 'Exec[ca_cert_update]',
              }
            )
            is_expected.to contain_file("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
              {
                'ensure' => 'file',
                'owner' => 'root',
                'group' => ca_file_group,
                'mode' => ca_file_mode,
                'notify' => 'Exec[ca_cert_update]',
              }
            )
          end
        end
      end

      context 'with ensure set to "trusted"' do
        let(:params) { { ensure: 'trusted' } }

        it { is_expected.not_to contain_archive("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}") }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to contain_exec("trust ca #{title}.#{ca_file_extension}") }
          it { is_expected.not_to contain_file("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}") }
        else
          it { is_expected.not_to contain_exec("#{title}.#{ca_file_extension}") }

          it do
            is_expected.to contain_file("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
              {
                'ensure' => 'absent',
                'notify' => 'Exec[ca_cert_update]',
              }
            )
          end
        end
      end

      context 'with ensure set to "distrusted" and no source or content' do
        let(:params) { { ensure: 'distrusted' } }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to contain_exec("distrust ca #{title}.#{ca_file_extension}") }
          it { is_expected.not_to contain_archive("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}") }
          it { is_expected.not_to contain_file("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}") }
        else
          it { is_expected.to compile.and_raise_error(%r{Either `source` or `content` is required}) }
        end
      end

      context 'with ensure set to "distrusted" and valid source' do
        let(:params) { { ensure: 'distrusted', source: 'puppet:///testing.crt' } }

        case facts[:os]['family']
        when 'Debian'
          it { is_expected.to contain_exec("distrust ca #{title}.#{ca_file_extension}") }
          it { is_expected.not_to contain_archive("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}") }
          it { is_expected.not_to contain_file("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}") }
        else
          it { is_expected.not_to contain_exec("distrust ca #{title}.#{ca_file_extension}") }

          it do
            is_expected.to contain_archive("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
              {
                'ensure'         => 'present',
                'source'         => 'puppet:///testing.crt',
                'checksum'       => nil,
                'checksum_type'  => nil,
                'allow_insecure' => false,
                'before'         => ["File[#{distrusted_cert_dir}/#{title}.#{ca_file_extension}]"],
                'notify'         => 'Exec[ca_cert_update]',
              }
            )
            is_expected.to contain_file("#{distrusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
              {
                'ensure' => 'file',
                'owner' => 'root',
                'group' => ca_file_group,
                'mode' => ca_file_mode,
                'notify' => 'Exec[ca_cert_update]',
              }
            )
          end
        end
      end

      context 'with ensure set to "absent"' do
        let(:params) { { ensure: 'absent' } }

        it do
          is_expected.to contain_file("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").only_with(
            {
              'ensure' => 'absent',
              'notify' => 'Exec[ca_cert_update]',
            }
          )
        end
      end

      context 'with allow_insecure_source set to true' do
        let(:params) { { allow_insecure_source: true, source: 'https://www.myorg.com/testing.pem' } }

        it { is_expected.to contain_archive("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").with_allow_insecure(true) }
      end

      context 'with checksum' do
        let(:params) { { checksum: 'testing', source: 'https://www.myorg.com/testing.pem' } }

        it { is_expected.to contain_archive("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").with_checksum('testing') }
      end

      context 'with checksum_type' do
        let(:params) { { checksum_type: 'testing', source: 'https://www.myorg.com/testing.pem' } }

        it { is_expected.to contain_archive("#{trusted_cert_dir}/#{title}.#{ca_file_extension}").with_checksum_type('testing') }
      end
    end
  end
end
