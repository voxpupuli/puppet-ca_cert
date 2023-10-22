require 'spec_helper'

describe 'ca_cert::ca', type: :define do
  let(:title) { 'Globalsign_Org_Intermediate' }
  let(:pre_condition) { 'class {"ca_cert": }' }

  on_supported_os.sort.each do |os, facts|
    # define os specific defaults
    case facts[:os]['family']
    when 'Debian'
      ca_file_mode        = '0444'
      trusted_cert_dir    = '/usr/local/share/ca-certificates'
      if facts[:os]['name'] == 'Debian'
      end
    when 'RedHat'
      trusted_cert_dir    = '/etc/pki/ca-trust/source/anchors'
      distrusted_cert_dir = '/etc/pki/ca-trust/source/blacklist'
    when 'Archlinux'
      trusted_cert_dir    = '/etc/ca-certificates/trust-source/anchors/'
      distrusted_cert_dir = '/etc/ca-certificates/trust-source/blacklist'
    when 'Suse'
      if %r{(10|11)}.match?(facts[:os]['release']['major'])
        ca_file_extension = 'pem'
        trusted_cert_dir  = '/etc/ssl/certs'
      else
        trusted_cert_dir    = '/etc/pki/trust/anchors'
        distrusted_cert_dir = '/etc/pki/trust/blacklist'
      end
    when 'AIX'
      ca_file_group    = 'system'
      trusted_cert_dir = '/var/ssl/certs'
    when 'Solaris'
      ca_file_extension = 'pem'
      ca_file_mode      = '0444'
      trusted_cert_dir  = '/etc/certs/CA/'
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
        it { is_expected.to contain_class('ca_cert::params') }
        it { is_expected.to contain_class('ca_cert::update') }
        it { is_expected.to contain_class('ca_cert::enable') }

        # only here to reach 100% resource coverage
        it { is_expected.to contain_ca_cert__ca('ca1') }
        it { is_expected.to contain_ca_cert__ca('ca2') }
        it { is_expected.to contain_exec('ca_cert_update') }
        it { is_expected.to contain_file('trusted_certs') }
        if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)} || facts[:os]['family'] == 'Solaris'
          it { is_expected.to contain_file('ca1.pem') }
          it { is_expected.to contain_file('ca2.pem') }
        else
          it { is_expected.to contain_file('ca1.crt') }
          it { is_expected.to contain_file('ca2.crt') }
        end
        if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)}
          it { is_expected.to contain_package('openssl-certs') }
        else
          it { is_expected.to contain_package('ca-certificates') }
        end
        if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'] =~ %r{(5|6)}
          it { is_expected.to contain_exec('enable_ca_trust') }
        end
        # /only here to reach 100% resource coverage

        it do
          is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
            {
              'ensure'  => 'file',
              'content' => 'testing',
              'path'    => trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Class[Ca_cert::Update]',
            },
          )
        end
      end

      context 'with source set to valid string "puppet:///testing.crt"' do
        let(:params) { { source: 'puppet:///testing.crt' } }

        if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)}
          it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{not proper format - SLES 10/11 CA Files must be in .pem format}) }
        else
          it do
            is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'  => 'file',
                'source'  => 'puppet:///testing.crt',
                'path'    => trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
                'owner'   => 'root',
                'group'   => ca_file_group,
                'mode'    => ca_file_mode,
                'notify'  => 'Class[Ca_cert::Update]',
              },
            )
          end
        end
      end

      context 'with source set to valid string "puppet:///testing.pem"' do
        let(:params) { { source: 'puppet:///testing.pem' } }

        it do
          is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
            {
              'ensure'  => 'file',
              'source'  => 'puppet:///testing.pem',
              'path'    => trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Class[Ca_cert::Update]',
            },
          )
        end
      end

      ['ftp', 'https', 'http'].each do |protocol|
        context "with source set to valid string \"#{protocol}://testing.crt\"" do
          let(:params) { { source: protocol + '://testing.crt' } }

          if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)}
            it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{not proper format - SLES 10/11 CA Files must be in .pem format}) }
          else
            it do
              is_expected.to contain_archive(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
                {
                  'ensure'         => 'present',
                  'source'         => protocol + '://testing.crt',
                  'checksum'       => nil,
                  'checksum_type'  => nil,
                  'allow_insecure' => false,
                  'notify'         => 'Class[Ca_cert::Update]',
                },
              )
            end
          end
        end

        context "with source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { source: protocol + '://testing.pem' } }

          it do
            is_expected.to contain_archive(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'         => 'present',
                'source'         => protocol + '://testing.pem',
                'checksum'       => nil,
                'checksum_type'  => nil,
                'allow_insecure' => false,
                'notify'         => 'Class[Ca_cert::Update]',
              },
            )
          end
        end
      end

      context 'with source set to valid string "file:/testing.crt"' do
        let(:params) { { source: 'file:/testing.crt' } }

        if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)}
          it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{not proper format - SLES 10/11 CA Files must be in .pem format}) }
        else
          it do
            is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'  => 'file',
                'source'  => '/testing.crt',
                'path'    => trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
                'owner'   => 'root',
                'group'   => ca_file_group,
                'mode'    => ca_file_mode,
                'notify'  => 'Class[Ca_cert::Update]',
              },
            )
          end
        end
      end

      context 'with source set to valid string "file:/testing.pem"' do
        let(:params) { { source: 'file:/testing.pem' } }

        it do
          is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
            {
              'ensure'  => 'file',
              'source'  => '/testing.pem',
              'path'    => trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Class[Ca_cert::Update]',
            },
          )
        end
      end

      context 'with ensure set to valid string "present"' do
        let(:params) { { ensure: 'present' } }

        it do
          is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
            {
              'ensure'  => 'file',
              'content' => nil,
              'path'    => trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
              'owner'   => 'root',
              'group'   => ca_file_group,
              'mode'    => ca_file_mode,
              'notify'  => 'Class[Ca_cert::Update]',
            },
          )
        end
      end

      context 'with ensure set to valid string "distrusted"' do
        let(:params) { { ensure: 'distrusted' } }

        it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{ca_text is required if source is set to text}) }
      end

      context 'with ensure set to valid string "distrusted" when source is "file:/dummy.pem"' do
        let(:params) { { ensure: 'distrusted', source: 'file:/dummy.pem' } }

        if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)} || facts[:os]['family'] == 'Debian'
          it do
            is_expected.to contain_file(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'  => 'absent',
                'notify'  => 'Class[Ca_cert::Update]',
              },
            )
          end
        elsif facts[:os]['family'] == 'Solaris' || facts[:os]['family'] == 'AIX'
          # fails on Solaris and AIX because ca_cert::params::distrusted_cert_dir is not defined
        else
          it do
            is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'  => 'file',
                'source'  => '/dummy.pem',
                'path'    => distrusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
                'owner'   => 'root',
                'group'   => ca_file_group,
                'mode'    => ca_file_mode,
                'notify'  => 'Class[Ca_cert::Update]',
              },
            )
          end
        end
      end

      context 'with ensure set to valid string "distrusted" when ca_text is "testing"' do
        let(:params) { { ensure: 'distrusted', ca_text: 'testing' } }

        if facts[:os]['family'] == 'Suse' && facts[:os]['release']['major'] =~ %r{(10|11)} || facts[:os]['family'] == 'Debian'
          it do
            is_expected.to contain_file(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'  => 'absent',
                'notify'  => 'Class[Ca_cert::Update]',
              },
            )
          end
        elsif facts[:os]['family'] == 'Solaris' || facts[:os]['family'] == 'AIX'
          # fails on Solaris and AIX because ca_cert::params::distrusted_cert_dir is not defined
        else
          it do
            is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
              {
                'ensure'  => 'file',
                'content' => 'testing',
                'path'    => distrusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension,
                'owner'   => 'root',
                'group'   => ca_file_group,
                'mode'    => ca_file_mode,
                'notify'  => 'Class[Ca_cert::Update]',
              },
            )
          end
        end
      end

      context 'with ensure set to valid string "absent"' do
        let(:params) { { ensure: 'absent' } }

        it do
          is_expected.to contain_file(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).only_with(
            {
              'ensure'  => 'absent',
              'notify'  => 'Class[Ca_cert::Update]',
            },
          )
        end
      end

      ['ftp', 'https', 'http'].each do |protocol|
        context "with verify_https_cert set to valid false when source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { verify_https_cert: false, source: protocol + '://testing.pem' } }

          it { is_expected.to contain_archive(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).with_allow_insecure(true) }
        end

        context "with checksum set to valid value when source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { checksum: 'testing', source: protocol + '://testing.pem' } }

          it { is_expected.to contain_archive(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).with_checksum('testing') }
        end

        context "with checksum_type set to valid value when source set to valid string \"#{protocol}://testing.pem\"" do
          let(:params) { { checksum_type: 'testing', source: protocol + '://testing.pem' } }

          it { is_expected.to contain_archive(trusted_cert_dir + '/Globalsign_Org_Intermediate.' + ca_file_extension).with_checksum_type('testing') }
        end
      end

      context 'with ca_file_group set to valid value when ca_text set to valid value' do
        let(:params) { { ca_file_group: 'testing', ca_text: 'dummy' } }

        it { is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).with_group('testing') }
      end

      ['puppet:///', 'file:/'].each do |protocol|
        context "with ca_file_group set to valid value when source set to valid string \"#{protocol}dummy.pem\"" do
          let(:params) { { ca_file_group: 'testing', source: protocol + 'dummy.pem' } }

          it { is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).with_group('testing') }
        end
      end

      context 'with ca_file_mode set to valid value when ca_text set to valid value' do
        let(:params) { { ca_file_mode: 'testing', ca_text: 'dummy' } }

        it { is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).with_mode('testing') }
      end

      ['puppet:///', 'file:/'].each do |protocol|
        context "with ca_file_mode set to valid value when source set to valid string \"#{protocol}dummy.pem\"" do
          let(:params) { { ca_file_mode: 'testing', source: protocol + 'dummy.pem' } }

          it { is_expected.to contain_file('Globalsign_Org_Intermediate.' + ca_file_extension).with_mode('testing') }
        end
      end
    end
  end
end
