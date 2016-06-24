require 'spec_helper'

describe 'ca_cert::ca', :type => :define do
  HTTP_URL  = 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.crt'
  DEBIAN_CA_FILE = '/usr/local/share/ca-certificates/Globalsign_Org_Intermediate.crt'
  REDHAT_CA_FILE = '/etc/pki/ca-trust/source/anchors/Globalsign_Org_Intermediate.crt'
  SUSE_11_HTTP_URL = 'http://secure.globalsign.com/cacert/gsorganizationvalsha2g2r1.pem'
  SUSE_11_CA_FILE = '/etc/ssl/certs/Globalsign_Org_Intermediate.pem'
  SUSE_12_CA_FILE = '/etc/pki/trust/anchors/Globalsign_Org_Intermediate.crt'
  DISTRUSTED_SUSE_12_CA_FILE = '/etc/pki/trust/blacklist/Globalsign_Org_Intermediate.crt'
  DISTRUSTED_REDHAT_CA_FILE = '/etc/pki/ca-trust/source/blacklist/Globalsign_Org_Intermediate.crt'
  GLOBALSIGN_ORG_CA = '-----BEGIN CERTIFICATE-----
MIIEaTCCA1GgAwIBAgILBAAAAAABRE7wQkcwDQYJKoZIhvcNAQELBQAwVzELMAkG
A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNVBAsTB1Jv
b3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xNDAyMjAxMDAw
MDBaFw0yNDAyMjAxMDAwMDBaMGYxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
YWxTaWduIG52LXNhMTwwOgYDVQQDEzNHbG9iYWxTaWduIE9yZ2FuaXphdGlvbiBW
YWxpZGF0aW9uIENBIC0gU0hBMjU2IC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQDHDmw/I5N/zHClnSDDDlM/fsBOwphJykfVI+8DNIV0yKMCLkZc
C33JiJ1Pi/D4nGyMVTXbv/Kz6vvjVudKRtkTIso21ZvBqOOWQ5PyDLzm+ebomchj
SHh/VzZpGhkdWtHUfcKc1H/hgBKueuqI6lfYygoKOhJJomIZeg0k9zfrtHOSewUj
mxK1zusp36QUArkBpdSmnENkiN74fv7j9R7l/tyjqORmMdlMJekYuYlZCa7pnRxt
Nw9KHjUgKOKv1CGLAcRFrW4rY6uSa2EKTSDtc7p8zv4WtdufgPDWi2zZCHlKT3hl
2pK8vjX5s8T5J4BO/5ZS5gIg4Qdz6V0rvbLxAgMBAAGjggElMIIBITAOBgNVHQ8B
Af8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUlt5h8b0cFilT
HMDMfTuDAEDmGnwwRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUHAgEWJmh0
dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDMGA1UdHwQsMCow
KKAmoCSGImh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5uZXQvcm9vdC5jcmwwPQYIKwYB
BQUHAQEEMTAvMC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWxzaWduLmNv
bS9yb290cjEwHwYDVR0jBBgwFoAUYHtmGkUNl8qJUC99BM00qP/8/UswDQYJKoZI
hvcNAQELBQADggEBAEYq7l69rgFgNzERhnF0tkZJyBAW/i9iIxerH4f4gu3K3w4s
32R1juUYcqeMOovJrKV3UPfvnqTgoI8UV6MqX+x+bRDmuo2wCId2Dkyy2VG7EQLy
XN0cvfNVlg/UBsD84iOKJHDTu/B5GqdhcIOKrwbFINihY9Bsrk8y1658GEV1BSl3
30JAZGSGvip2CTFvHST0mdCF/vIhCPnG9vHQWe3WVjwIKANnuvD58ZAWR65n5ryA
SOlCdjSXVWkkDoPWoC209fN5ikkodBpBocLTJIg1MGCUF7ThBCIxPTsvFwayuJ2G
K1pp74P1S8SqtCr4fKGxhZSM9AyHDPSsQPhZSZg=
-----END CERTIFICATE-----'

  let :pre_condition do
    'class {"ca_cert": }'
  end

  let :title do
    'Globalsign_Org_Intermediate'
  end

  let :debian_facts do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
    }
  end

  let :redhat_facts do
    {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
    }
  end

  let :suse_11_facts do
    {
      :osfamily => 'Suse',
      :operatingsystem => 'Suse',
      :operatingsystemmajrelease => '11',
    }
  end

  let :suse_12_facts do
    {
      :osfamily => 'Suse',
      :operatingsystem => 'Suse',
      :operatingsystemmajrelease => '12',
    }
  end

  shared_examples 'compiles and includes main and params classes' do
    it { should compile }
    it { is_expected.to contain_class("ca_cert") }
    it { is_expected.to contain_class("ca_cert::params") }
  end

  describe 'failure conditions' do
    let :facts do debian_facts end

    context 'with no certificate text' do
      let :params do
        {
          :source => 'text',
        }
      end
      it { expect { should raise_error(Puppet::Error, /ca_text is required if source is set to text/) }}
    end

    context 'with an invalid source' do
      let :params do
        {
          :source => 'rsync://certificate.crt',
        }
      end
      it { expect { should raise_error(Puppet::Error, /Protocol must be puppet, file, http, https, ftp, or text/) }}
    end
  end

  describe 'os-dependent items' do
    context "On Debian based systems" do
      let :facts do debian_facts end
      let :params do
        {
          :source => HTTP_URL
        }
      end
      it_behaves_like 'compiles and includes main and params classes' do
      end
      describe 'with a remote certificate' do
        let :params do
          {
            :source => HTTP_URL
          }
        end
        it { is_expected.to contain_exec("get_Globalsign_Org_Intermediate.crt").with(
            'creates' => DEBIAN_CA_FILE,
            'command' => "wget  -O #{DEBIAN_CA_FILE} #{HTTP_URL} 2> /dev/null",
          )
        }
        it { is_expected.not_to contain_file(DEBIAN_CA_FILE) }
      end
      describe 'with the certificate delivered as a string' do
        let :params do
          {
            :source  => 'text',
            :ca_text => GLOBALSIGN_ORG_CA,
          }
        end
        it { is_expected.to contain_file('Globalsign_Org_Intermediate.crt').with(
          'ensure'  => 'present',
          'content' => GLOBALSIGN_ORG_CA,
          'path'    => DEBIAN_CA_FILE,
        ) }
      end
      describe "when removing the CA cert" do
        ['absent', 'distrusted'].each do |deb_ensure|
          let :params do
            {
              :ensure => deb_ensure,
              :source => HTTP_URL,
            }
          end
          context "with ensure set to #{deb_ensure}" do
            it { is_expected.to contain_file(DEBIAN_CA_FILE).with(
              'ensure' => 'absent'
            ) }
          end
        end
      end
    end

    context "On RedHat based systems" do
      let :facts do redhat_facts end
      let :params do
        {
          :source => HTTP_URL
        }
      end

      it_behaves_like 'compiles and includes main and params classes' do
      end

      describe 'with a remote certificate' do
        let :params do
          {
            :source => HTTP_URL,
          }
        end

        it { is_expected.to contain_exec("get_Globalsign_Org_Intermediate.crt").with(
            'creates' => REDHAT_CA_FILE,
            'command' => "wget  -O #{REDHAT_CA_FILE} #{HTTP_URL} 2> /dev/null",
          ) }
        it { is_expected.not_to contain_file(REDHAT_CA_FILE) }
      end
      describe 'with the certificate delivered as a string' do
        let :params do
          {
            :source  => 'text',
            :ca_text => GLOBALSIGN_ORG_CA,
          }
        end
        it { is_expected.to contain_file('Globalsign_Org_Intermediate.crt').with(
          'ensure'  => 'present',
          'content' => GLOBALSIGN_ORG_CA,
          'path'    => REDHAT_CA_FILE,
        ) }
      end
      describe "when removing the CA cert" do
        let :params do
          {
            :ensure => 'absent',
          }
        end
        it { is_expected.to contain_file(REDHAT_CA_FILE).with(
          'ensure' => 'absent'
        )}
      end
      describe "when explicitly distrusting a certificate" do
        let :params do
          {
            :source => HTTP_URL,
            :ensure => 'distrusted',
          }
        end
        it { is_expected.to contain_exec("get_Globalsign_Org_Intermediate.crt").with(
          'creates' => DISTRUSTED_REDHAT_CA_FILE,
          'command' => "wget  -O #{DISTRUSTED_REDHAT_CA_FILE} #{HTTP_URL} 2> /dev/null",
        )}
      end
    end

    context "On Suse 11 based systems" do
      let :facts do suse_11_facts end
      let :params do
        {
          :source => SUSE_11_HTTP_URL
        }
      end

      it_behaves_like 'compiles and includes main and params classes' do
      end

      describe 'with a remote certificate' do
        let :params do
          {
            :source => SUSE_11_HTTP_URL,
          }
        end

        it { is_expected.to contain_exec("get_Globalsign_Org_Intermediate.pem").with(
            'creates' => SUSE_11_CA_FILE,
            'command' => "wget  -O #{SUSE_11_CA_FILE} #{SUSE_11_HTTP_URL} 2> /dev/null",
          ) }
        it { is_expected.not_to contain_file(SUSE_11_CA_FILE) }
      end
      describe 'with the certificate delivered as a string' do
        let :params do
          {
            :source  => 'text',
            :ca_text => GLOBALSIGN_ORG_CA,
          }
        end
        it { is_expected.to contain_file('Globalsign_Org_Intermediate.pem').with(
          'ensure'  => 'present',
          'content' => GLOBALSIGN_ORG_CA,
          'path'    => SUSE_11_CA_FILE,
        ) }
      end
      describe "when removing the CA cert" do
        let :params do
          {
            :ensure => 'absent',
          }
        end
        it { is_expected.to contain_file(SUSE_11_CA_FILE).with(
          'ensure' => 'absent'
        )}
      end
      describe "when removing the CA cert" do
        ['absent', 'distrusted'].each do |suse_ensure|
          let :params do
            {
              :ensure => suse_ensure,
              :source => SUSE_11_HTTP_URL,
            }
          end
          context "with ensure set to #{suse_ensure}" do
            it { is_expected.to contain_file(SUSE_11_CA_FILE).with(
              'ensure' => 'absent'
            ) }
          end
        end
      end
    end

    context "On Suse 12 based systems" do
      let :facts do suse_12_facts end
      let :params do
        {
          :source => HTTP_URL
        }
      end

      it_behaves_like 'compiles and includes main and params classes' do
      end

      describe 'with a remote certificate' do
        let :params do
          {
            :source => HTTP_URL,
          }
        end

        it { is_expected.to contain_exec("get_Globalsign_Org_Intermediate.crt").with(
            'creates' => SUSE_12_CA_FILE,
            'command' => "wget  -O #{SUSE_12_CA_FILE} #{HTTP_URL} 2> /dev/null",
          ) }
        it { is_expected.not_to contain_file(SUSE_12_CA_FILE) }
      end
      describe 'with the certificate delivered as a string' do
        let :params do
          {
            :source  => 'text',
            :ca_text => GLOBALSIGN_ORG_CA,
          }
        end
        it { is_expected.to contain_file('Globalsign_Org_Intermediate.crt').with(
          'ensure'  => 'present',
          'content' => GLOBALSIGN_ORG_CA,
          'path'    => SUSE_12_CA_FILE,
        ) }
      end
      describe "when removing the CA cert" do
        let :params do
          {
            :ensure => 'absent',
          }
        end
        context "with ensure set to absent" do
          it { is_expected.to contain_file(SUSE_12_CA_FILE).with(
            'ensure' => 'absent'
          ) }
        end
      end
      describe "when explicitly distrusting a certificate" do
        let :params do
          {
            :source => HTTP_URL,
            :ensure => 'distrusted',
          }
        end
        it { is_expected.to contain_exec("get_Globalsign_Org_Intermediate.crt").with(
          'creates' => DISTRUSTED_SUSE_12_CA_FILE,
          'command' => "wget  -O #{DISTRUSTED_SUSE_12_CA_FILE} #{HTTP_URL} 2> /dev/null",
        )}
      end
    end
  end
end
