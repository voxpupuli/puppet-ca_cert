require 'spec_helper'

describe 'ca_cert::params', :type => :class do
  [
    'Debian',
    'RedHat',
  ].each do |osfamily|
    let :facts do
      {
        :osfamily => osfamily
      }
    end
    context "with osfamily #{osfamily}" do

      it { is_expected.to contain_ca_cert__params }

      it "should not contain any resources" do
        should have_resource_count(0)
      end
    end
  end
  context "on an unsupported operating system" do
    let :facts do
      {
        :osfamily => 'Solaris'
      }
    end

    it { expect {catalogue}.to raise_error Puppet::Error, /Unsupported osfamily/ }

  end
end
