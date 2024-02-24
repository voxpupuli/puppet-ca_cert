require 'spec_helper'

describe 'ca_cert::params', type: :class do
  shared_examples 'compiles and includes params class' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('ca_cert::params') }
  end

  %w[
    Debian
    RedHat
  ].each do |osfamily|
    let :facts do
      {
        'os' => {
          'family' => osfamily,
        },
      }
    end

    context "with osfamily #{osfamily}" do
      it_behaves_like 'compiles and includes params class' do
      end
      it 'does not contain any resources' do
        is_expected.to have_resource_count(0)
      end
    end
  end

  %w[10 11 12].each do |osmajrel|
    context "On a Suse #{osmajrel} Operating System" do
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
      it 'does not contain any resources' do
        is_expected.to have_resource_count(0)
      end
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
