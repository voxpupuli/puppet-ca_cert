require 'spec_helper'

describe 'ca_cert::params', type: :class do
  on_supported_os.sort.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }
      it { is_expected.to have_resource_count(0) }
    end
  end

  context 'on an unsupported operating system' do
    let(:facts) { { 'os' => { 'family' => 'WeirdOS' } } }

    it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{Unsupported osfamily}) }
  end

  context 'on an unsupported Solaris system' do
    let(:facts) { { 'os' => { 'family' => 'Solaris', 'release' => { 'major' => '10' } } } }

    it { expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{Unsupported OS Major release}) }
  end
end
