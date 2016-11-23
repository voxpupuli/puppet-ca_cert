require 'spec_helper'

describe 'ca_cert::update', :type => :class do

  shared_examples 'compiles and includes params class' do
    it { should compile }
    it { should contain_class('ca_cert::params') }
  end

  context "on a Debian based OS" do
    let :facts do
      {
        :osfamily => 'Debian',
      }
    end

    it_behaves_like 'compiles and includes params class' do
    end
    it { is_expected.not_to contain_exec('enable_ca_trust') }
    it { is_expected.to contain_exec('ca_cert_update').with(
      :command     => 'update-ca-certificates',
      :refreshonly => true,
    )}

  end
  context "on a RedHat based OS" do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    it_behaves_like 'compiles and includes params class' do
    end
    it { is_expected.to contain_exec('enable_ca_trust').with(
      :command => 'update-ca-trust enable',
    ) }
    it { is_expected.to contain_exec('ca_cert_update').with(
      :command     => 'update-ca-trust extract',
      :refreshonly => true,
    )}

  end
  ['10','11'].each do |osmajrel|
    context "on a Suse #{osmajrel} based OS" do
      let :facts do
        {
          :osfamily => 'Suse',
          :operatingsystemmajrelease => "#{osmajrel}",
        }
      end

      it_behaves_like 'compiles and includes params class' do
      end
      it { is_expected.not_to contain_exec('enable_ca_trust') }
      it { is_expected.to contain_exec('ca_cert_update').with(
        :command     => 'c_rehash',
        :refreshonly => true,
      )}

    end
  end
  context "on a Suse 12 based OS" do
    let :facts do
      {
        :osfamily => 'Suse',
        :operatingsystemmajrelease => '12',
      }
    end

    it_behaves_like 'compiles and includes params class' do
    end
    it { is_expected.not_to contain_exec('enable_ca_trust') }
    it { is_expected.to contain_exec('ca_cert_update').with(
      :command     => 'update-ca-certificates',
      :refreshonly => true,
    )}

  end
end
