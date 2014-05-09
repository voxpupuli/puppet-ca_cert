require 'spec_helper_acceptance'

describe 'ca_cert::ca', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  case fact('osfamily')
  when 'Debian'
    TRUSTED_CA_FILE = '/usr/local/share/ca-certificates/Globalsign_Org_Intermediate.crt'
    ABSENT_CA_FILE = '/etc/pki/ca-trust/source/blacklist/CACert.crt'
  when 'RedHat'
    TRUSTED_CA_FILE = '/etc/pki/ca-trust/source/anchors/Globalsign_Org_Intermediate.crt'
    UNTRUSTED_CA_FILE = '/etc/pki/ca-trust/source/blacklist/CACert.crt'
  end

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'ca_cert': }

        ca_cert::ca { 'Globalsign_Org_Intermediate':
          source => 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt',
        }

        ca_cert::ca { 'CACert':
          source => 'http://www.cacert.org/certs/root.crt',
          ensure => 'distrusted',
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end
    
    describe file(TRUSTED_CA_FILE) do
      it { should be_file }
    end

    case fact('osfamily')
    when 'Debian'
      describe file(ABSENT_CA_FILE) do
        it { should_not be_file }
      end
    when 'RedHat'
      describe file(UNTRUSTED_CA_FILE) do
        it { should be_file }
      end
    end
  end
end
