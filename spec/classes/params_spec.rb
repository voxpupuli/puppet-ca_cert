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

      it { should contain_ca_cert__params }

      it "should not contain any resources" do
        # Contains class[ca_cert::params], class[main], stage[main], and
        # class[settings]
        subject.resources.size.should == 4
      end
    end
  end
  context "on an unsupported operating system" do
    let :facts do
      {
        :osfamily => 'Solaris'
      }
    end

    it { expect { should raise_error(Puppet::Error, /Unsupported osfamily (Solaris)/) }}
  end
end
