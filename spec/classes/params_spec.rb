require 'spec_helper'

describe 'ca_cert::params', :type => :class do

  shared_examples 'compiles and includes params class' do
    it { should compile }
    it { should contain_class('ca_cert::params') }
  end

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

    it_behaves_like 'compiles and includes params class' do
    end
      it "should not contain any resources" do
        should have_resource_count(0)
      end
    end
  end

  ['10','11','12'].each do |osmajrel|
    context "On a Suse #{osmajrel} Operating System" do
      let :facts do
        {
          :osfamily => 'Suse',
          :operatingsystemmajrelease => "#{osmajrel}",
        }
      end

      it_behaves_like 'compiles and includes params class' do
      end
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
