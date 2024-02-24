require 'spec_helper'

describe 'ca_cert', type: :class do
  shared_examples 'compiles and includes params class' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('ca_cert::params') }
    it { is_expected.to contain_ca_cert__ca('ca1') }
    it { is_expected.to contain_ca_cert__ca('ca2') }
  end

  context 'on a Debian based OS' do
    let :facts do
      {
        'os' => {
          'family' => 'Debian',
          'name'   => 'Ubuntu',
        },
      }
    end

    it_behaves_like 'compiles and includes params class' do
    end
    it { is_expected.to contain_package('ca-certificates') }

    it {
      is_expected.to contain_file('trusted_certs').with(
        'ensure' => 'directory',
        'path'   => '/usr/local/share/ca-certificates',
        'group'  => 'staff',
        'purge'  => 'false'
      )
    }

    context 'with purge_unmanaged_CAs set to true' do
      let :params do
        {
          purge_unmanaged_CAs: true,
        }
      end

      it {
        is_expected.to contain_file('trusted_certs').with(
          'ensure' => 'directory',
          'path'   => '/usr/local/share/ca-certificates',
          'group'  => 'staff',
          'purge'  => 'true'
        )
      }
    end
  end

  context 'on a RedHat based OS' do
    let :facts do
      {
        'os' => {
          'family'  => 'RedHat',
          'release' => {
            'major' => '7',
            'minor' => '0',
            'full'  => '7.0',
          },
        },
      }
    end

    it_behaves_like 'compiles and includes params class' do
    end
    it { is_expected.to contain_package('ca-certificates') }

    it {
      is_expected.to contain_file('trusted_certs').with(
        'ensure' => 'directory',
        'path'   => '/etc/pki/ca-trust/source/anchors',
        'group'  => 'root',
        'purge'  => 'false'
      )
    }

    context 'with purge_unmanaged_CAs set to true' do
      let :params do
        {
          purge_unmanaged_CAs: true,
        }
      end

      it {
        is_expected.to contain_file('trusted_certs').with(
          'ensure' => 'directory',
          'path'   => '/etc/pki/ca-trust/source/anchors',
          'group'  => 'root',
          'purge'  => 'true'
        )
      }
    end
  end

  %w[10 11].each do |osmajrel|
    context "on a Suse #{osmajrel} based OS" do
      let :facts do
        {
          'os' => {
            'family'  => 'Suse',
            'release' => {
              'major' => osmajrel.to_s,
            },
          },
        }
      end

      it_behaves_like 'compiles and includes params class' do
      end
      it { is_expected.to contain_package('openssl-certs') }

      it {
        is_expected.to contain_file('trusted_certs').with(
          'ensure' => 'directory',
          'path'   => '/etc/ssl/certs',
          'group'  => 'root',
          'purge'  => 'false'
        )
      }

      context 'with purge_unmanaged_CAs set to true' do
        let :params do
          {
            purge_unmanaged_CAs: true,
          }
        end

        it {
          is_expected.to contain_file('trusted_certs').with(
            'ensure' => 'directory',
            'path'   => '/etc/ssl/certs',
            'group'  => 'root',
            'purge'  => 'true'
          )
        }
      end
    end
  end

  context 'on a Suse 12 based OS' do
    let :facts do
      {
        'os' => {
          'family'  => 'Suse',
          'release' => {
            'major' => '12',
          },
        },
      }
    end

    it_behaves_like 'compiles and includes params class' do
    end
    it { is_expected.to contain_package('ca-certificates') }

    it {
      is_expected.to contain_file('trusted_certs').with(
        'ensure' => 'directory',
        'path'   => '/etc/pki/trust/anchors',
        'group'  => 'root',
        'purge'  => 'false'
      )
    }

    context 'with purge_unmanaged_CAs set to true' do
      let :params do
        {
          purge_unmanaged_CAs: true,
        }
      end

      it {
        is_expected.to contain_file('trusted_certs').with(
          'ensure' => 'directory',
          'path'   => '/etc/pki/trust/anchors',
          'group'  => 'root',
          'purge'  => 'true'
        )
      }
    end
  end

  context 'on an unsupported operating system' do
    let :facts do
      {
        'os' => {
          'family' => 'WeirdOS',
        },
      }
    end

    it { expect { catalogue }.to raise_error Puppet::Error, %r{Unsupported osfamily} }
  end
end
