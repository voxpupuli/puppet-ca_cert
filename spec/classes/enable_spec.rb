require 'spec_helper'

describe 'ca_cert::enable', type: :class do
  on_supported_os.sort.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('ca_cert') }

      if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_i < 7
        it do
          is_expected.to contain_exec('enable_ca_trust').only_with(
            {
              'command'   => 'update-ca-trust enable',
              'logoutput' => 'on_failure',
              'path'      => ['/usr/sbin', '/usr/bin', '/bin'],
              'onlyif'    => 'update-ca-trust check | grep DISABLED',
            },
          )
        end
      end

      # only here to reach 100% resource coverage
      it { is_expected.to contain_ca_cert__ca('ca1') }
      it { is_expected.to contain_ca_cert__ca('ca2') }
      it { is_expected.to contain_class('ca_cert::update') }
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
      # /only here to reach 100% resource coverage
    end

    context "on #{os} when ca_cert::force_enable is true" do
      let(:facts) { facts }
      let(:pre_condition) { 'class { ca_cert: force_enable => true }' }

      if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_i < 7
        it do
          is_expected.to contain_exec('enable_ca_trust').only_with(
            {
              'command'   => 'update-ca-trust force-enable',
              'logoutput' => 'on_failure',
              'path'      => ['/usr/sbin', '/usr/bin', '/bin'],
              'onlyif'    => 'update-ca-trust check | grep DISABLED',
            },
          )
        end
      end
    end
  end
end
