require 'spec_helper'

describe 'ca_cert::update', type: :class do
  on_supported_os.sort.each do |os, facts|
    # define os specific defaults
    case facts[:os]['family']
    when 'RedHat'
      update_cmd = 'update-ca-trust extract'
    when 'Archlinux'
      update_cmd = 'trust extract-compat'
    when 'Suse'
      update_cmd = if %r{(10|11)}.match?(facts[:os]['release']['major'])
                     'c_rehash'
                   else
                     'update-ca-certificates'
                   end
    when 'AIX'
      update_cmd = '/usr/bin/c_rehash'
    when 'Solaris'
      update_cmd = '/usr/sbin/svcadm restart /system/ca-certificates'
    end

    update_cmd = 'update-ca-certificates' if update_cmd.nil?

    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('ca_cert') }
      it { is_expected.to contain_class('ca_cert::enable') }

      # only here to reach 100% resource coverage
      it { is_expected.to contain_ca_cert__ca('ca1') }
      it { is_expected.to contain_ca_cert__ca('ca2') }
      it { is_expected.to contain_file('trusted_certs') }
      if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_i < 7
        it { is_expected.to contain_exec('enable_ca_trust') }
      end
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

      it do
        is_expected.to contain_exec('ca_cert_update').only_with(
          {
            'command'     => update_cmd,
            'logoutput'   => 'on_failure',
            'refreshonly' => true,
            'path'        => ['/usr/sbin', '/usr/bin', '/bin'],
          },
        )
      end
    end
  end
end
