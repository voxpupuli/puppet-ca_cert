require 'spec_helper'

describe 'ca_cert', :type => :class do
  context "on a Debian based OS" do
    let :facts do
      {
        :osfamily => 'Debian',
      }
    end

    it { is_expected.to contain_ca_cert__params }
    it { is_expected.to contain_package('ca-certificates') }

    it { is_expected.to contain_file("trusted_certs").with(
        'ensure' => 'directory',
        'path'   => '/usr/local/share/ca-certificates',
        'group'  => 'staff',
        'purge'  => 'false',
      )
    }

    context "with purge_unmanaged_CAs set to true" do
      let :params do
        {
          :purge_unmanaged_CAs => 'true',
        }
      end
      it { is_expected.to contain_file("trusted_certs").with(
          'ensure' => 'directory',
          'path'   => '/usr/local/share/ca-certificates',
          'group'  => 'staff',
          'purge'  => 'true',
        )
      }
    end
  end
  context "on a RedHat based OS" do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    it { is_expected.to contain_ca_cert__params }
    it { is_expected.to contain_package('ca-certificates') }

    it { is_expected.to contain_file("trusted_certs").with(
        'ensure' => 'directory',
        'path'   => '/etc/pki/ca-trust/source/anchors',
        'group'  => 'root',
        'purge'  => 'false',
      )
    }

    context "with purge_unmanaged_CAs set to true" do
      let :params do
        {
          :purge_unmanaged_CAs => 'true',
        }
      end
      it { is_expected.to contain_file("trusted_certs").with(
          'ensure' => 'directory',
          'path'   => '/etc/pki/ca-trust/source/anchors',
          'group'  => 'root',
          'purge'  => 'true',
        )
      }
    end
  end
  context "on a Solaris based OS" do
    let :facts do
      {
        :osfamily => 'Solaris',
      }
    end
    it "should fail" do
      expect do
        subject
      end.to raise_error(Puppet::Error)
    end
  end
end
