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
        # Contains class[ca_cert::params], class[main], stage[main], and
        # class[settings]
        expect(subject.resources.size).to eq(4)
      end
    end
  end
  context "on an unsupported operating system" do
    let :facts do
      {
        :osfamily => 'Solaris'
      }
    end

    it "should fail" do
      expect do
        subject
      end.to raise_error(Puppet::Error)
    end
  end
end
