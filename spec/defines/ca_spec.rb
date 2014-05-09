require 'spec_helper'

describe 'ca_cert::ca', :type => :define do
  HTTP_URL  = 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt'
  DEBIAN_CA_FILE = '/usr/local/share/ca-certificates/Globalsign_Org_Intermediate.crt'
  REDHAT_CA_FILE = '/etc/pki/ca-trust/source/anchors/Globalsign_Org_Intermediate.crt'
  DISTRUSTED_REDHAT_CA_FILE = '/etc/pki/ca-trust/source/blacklist/Globalsign_Org_Intermediate.crt'

  let :pre_condition do
    'class {"ca_cert": }'
  end

  let :title do
    'Globalsign_Org_Intermediate'
  end

  let :default_params do
    {
      :source => HTTP_URL
    }
  end

  let :debian_facts do
    {
      :osfamily => 'Debian',
    }
  end

  let :redhat_facts do
    {
      :osfamily => 'RedHat',
    }
  end

  describe 'os-dependent items' do
    context "On Debian based systems" do
      let :facts do debian_facts end
      let :params do default_params end
      it { should contain_class("ca_cert") }
      it { should contain_class("ca_cert::params") }
      it { should contain_exec("get_Globalsign_Org_Intermediate.crt").with(
          'creates' => DEBIAN_CA_FILE,
          'command' => "wget  -O #{DEBIAN_CA_FILE} #{HTTP_URL} 2> /dev/null",
        )
      }
      it { should_not contain_file(DEBIAN_CA_FILE) }
      describe "when removing the CA cert" do
        ['absent', 'distrusted'].each do |deb_ensure|
          let :params do
            super().merge({
              :ensure => deb_ensure,
            })
          end
          context "with ensure set to #{deb_ensure}" do
            it { should contain_file(DEBIAN_CA_FILE).with(
              'ensure' => 'absent'
            ) }
          end
        end
      end
    end
    
    context "On RedHat based systems" do
      let :facts do redhat_facts end
      let :params do default_params end
      it { should contain_class("ca_cert") }
      it { should contain_class("ca_cert::params") }
      it { should contain_exec("get_Globalsign_Org_Intermediate.crt").with(
          'creates' => REDHAT_CA_FILE,
          'command' => "wget  -O #{REDHAT_CA_FILE} #{HTTP_URL} 2> /dev/null",
        ) }
      it { should_not contain_file(REDHAT_CA_FILE) }
      context "when removing the CA cert" do
        let :params do
          super().merge({
            :ensure => 'absent',
          })
        end
        it { should contain_file(REDHAT_CA_FILE).with( 
          'ensure' => 'absent'
        )}
      end
      context "when explicitly distrusting a certificate" do
        let :params do
          super().merge({
            :ensure => 'distrusted'
          })
        end
        it { should contain_exec("get_Globalsign_Org_Intermediate.crt").with(
          'creates' => DISTRUSTED_REDHAT_CA_FILE,
          'command' => "wget  -O #{DISTRUSTED_REDHAT_CA_FILE} #{HTTP_URL} 2> /dev/null",
        )}
      end
    end
  end
end
