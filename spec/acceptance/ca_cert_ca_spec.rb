require 'spec_helper_acceptance'

case host_inventory['facter']['os']['family']
when 'Debian'
  trusted_ca_file_remote = '/usr/local/share/ca-certificates/DigiCert_G5_TLS_ECC_SHA384_2021_CA1.crt'
  trusted_ca_file_text = '/usr/local/share/ca-certificates/InCommon.crt'
  ca_certificates_conf = '/etc/ca-certificates.conf'
  ca_certificates_bundle = '/etc/ssl/certs/ca-certificates.crt'
when 'RedHat'
  trusted_ca_file_remote = '/etc/pki/ca-trust/source/anchors/DigiCert_G5_TLS_ECC_SHA384_2021_CA1.crt'
  trusted_ca_file_text = '/etc/pki/ca-trust/source/anchors/InCommon.crt'
  untrusted_ca_file_remote = '/etc/pki/ca-trust/source/blacklist/DigiCert_Global_Root_G3.crt'
  ca_certificates_bundle = '/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem'
when 'Archlinux'
  trusted_ca_file_remote = '/etc/ca-certificates/trust-source/anchors/DigiCert_G5_TLS_ECC_SHA384_2021_CA1.crt'
  trusted_ca_file_text = '/etc/ca-certificates/trust-source/anchors/InCommon.crt'
  untrusted_ca_file_remote = '/etc/ca-certificates/trust-source/blacklist/DigiCert_Global_Root_G3.crt'
  ca_certificates_bundle = '/etc/ca-certificates/extracted/tls-ca-bundle.pem'
end

describe 'ca_cert::ca' do
  context 'add local trusted ca certificates' do
    let(:manifest) do
      <<~EOS
        ca_cert::ca { 'DigiCert_G5_TLS_ECC_SHA384_2021_CA1':
          source => 'https://cacerts.digicert.com/DigiCertG5TLSECCSHA3842021CA1-1.crt.pem',
        }

        ca_cert::ca { 'InCommon':
          content => '-----BEGIN CERTIFICATE-----
        MIIEwzCCA6ugAwIBAgIQf3HB06ImsNKxE/PmgWdkPjANBgkqhkiG9w0BAQUFADBv
        MQswCQYDVQQGEwJTRTEUMBIGA1UEChMLQWRkVHJ1c3QgQUIxJjAkBgNVBAsTHUFk
        ZFRydXN0IEV4dGVybmFsIFRUUCBOZXR3b3JrMSIwIAYDVQQDExlBZGRUcnVzdCBF
        eHRlcm5hbCBDQSBSb290MB4XDTEwMTIwNzAwMDAwMFoXDTIwMDUzMDEwNDgzOFow
        UTELMAkGA1UEBhMCVVMxEjAQBgNVBAoTCUludGVybmV0MjERMA8GA1UECxMISW5D
        b21tb24xGzAZBgNVBAMTEkluQ29tbW9uIFNlcnZlciBDQTCCASIwDQYJKoZIhvcN
        AQEBBQADggEPADCCAQoCggEBAJd8x8j+s+kgaqOkT46ONFYGs3psqhCbSGErNpBp
        4zQKR6e7e96qavvrgpWPyh1/r3WmqEzaIGdhGg2GwcrBh6+sTuTeYhsvnbGYr8YB
        +xdw26wUWexvPzN/ppgL5OI4r/V/hW0OdASd9ieGx5uP53EqCPQDAkBjJH1AV49U
        4FR+thNIYfHezg69tvpNmLLZDY15puCqzQyRmqXfq3O7yhR4XEcpocrFup/H2mD3
        /+d/8tnaoS0PSRan0wCSz4pH2U341ZVm03T5gGMAT0yEFh+z9SQfoU7e6JXWsgsJ
        iyxrx1wvjGPJmctSsWJ7cwFif2Ns2Gig7mqojR8p89AYrK0CAwEAAaOCAXcwggFz
        MB8GA1UdIwQYMBaAFK29mHo0tCb3+sQmVO8DveAky1QaMB0GA1UdDgQWBBRIT1r6
        L0qaXuBQ82t7VaXe9b40XTAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB
        /wIBADARBgNVHSAECjAIMAYGBFUdIAAwRAYDVR0fBD0wOzA5oDegNYYzaHR0cDov
        L2NybC51c2VydHJ1c3QuY29tL0FkZFRydXN0RXh0ZXJuYWxDQVJvb3QuY3JsMIGz
        BggrBgEFBQcBAQSBpjCBozA/BggrBgEFBQcwAoYzaHR0cDovL2NydC51c2VydHJ1
        c3QuY29tL0FkZFRydXN0RXh0ZXJuYWxDQVJvb3QucDdjMDkGCCsGAQUFBzAChi1o
        dHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vQWRkVHJ1c3RVVE5TR0NDQS5jcnQwJQYI
        KwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVzdC5jb20wDQYJKoZIhvcNAQEF
        BQADggEBAJNmIYB0RYVLwqvOMrAp/t3f1iRbvwNqb1A+DhuzDYijW+7EpBI7Vu8G
        f89/IZVWO0Ex/uGqk9KV85UNPEerylwmrT7x+Yw0bhG+9GfjAkn5pnx7ZCXdF0by
        UOPjCiE6SSTNxoRlaGdosEUtR5nNnKuGKRFy3NacNkN089SXnlag/l9AWNLV1358
        xY4asgRckmYOha0uBs7Io9jrFCeR3s8XMIFTtmYSrTfk9e+WXCAONumsYn0ZgYr1
        kGGmSavOPN/mymTugmU5RZUWukEGAJi6DFZh5MbGhgHPZqkiKQLWPc/EKo2Z3vsJ
        FJ4O0dXG14HdrSSrrAcF4h1ow3BmX9M=
        -----END CERTIFICATE-----',
        }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe file(trusted_ca_file_remote) do
      it { is_expected.to be_file }
    end

    describe file(trusted_ca_file_text) do
      it { is_expected.to be_file }
    end

    describe file(ca_certificates_bundle) do
      its(:content) do
        # DigiCert_G5_TLS_ECC_SHA384_2021_CA1
        is_expected.to match %r{IvZuhDckSAkMNGICMQD4lvGyMGMQirgiqAaMdybUTpcDTLtRQPKiGVZOoSaRtq8o}
        # InCommon
        is_expected.to match %r{kGGmSavOPN/mymTugmU5RZUWukEGAJi6DFZh5MbGhgHPZqkiKQLWPc/EKo2Z3vsJ}
        # DigiCert_Global_Root_G3
        is_expected.to match %r{oAIwOWZbwmSNuJ5Q3KjVSaLtx9zRSX8XAbjIho9OjIgrqJqpisXRAL34VOKa5Vt8}
      end
    end
  end

  context 'distrust a os provided ca certificate' do
    let(:manifest) do
      <<~EOS
        ca_cert::ca { 'DigiCert_Global_Root_G3':
          source => 'https://cacerts.digicert.com/DigiCertGlobalRootG3.crt.pem',
          ensure => 'distrusted',
        }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    case host_inventory['facter']['os']['family']
    when 'Debian'
      describe file(ca_certificates_conf) do
        its(:content) { is_expected.to match %r{^!.*DigiCert_Global_Root_G3.crt} }
      end
    else
      describe file(untrusted_ca_file_remote) do
        it { is_expected.to be_file }
      end
    end

    describe file(ca_certificates_bundle) do
      its(:content) do
        # DigiCert_Global_Root_G3
        is_expected.not_to match %r{oAIwOWZbwmSNuJ5Q3KjVSaLtx9zRSX8XAbjIho9OjIgrqJqpisXRAL34VOKa5Vt8}
      end
    end
  end

  context 'trust a os provided ca certificate' do
    let(:manifest) do
      <<~EOS
        ca_cert::ca { 'DigiCert_Global_Root_G3':
          source => 'https://cacerts.digicert.com/DigiCertGlobalRootG3.crt.pem',
          ensure => 'trusted',
        }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    case host_inventory['facter']['os']['family']
    when 'Debian'
      describe file(ca_certificates_conf) do
        its(:content) { is_expected.to match %r{^[^!].*DigiCert_Global_Root_G3.crt} }
      end
    else
      describe file(untrusted_ca_file_remote) do
        it { is_expected.not_to exist }
      end
    end

    describe file(ca_certificates_bundle) do
      its(:content) do
        # DigiCert_Global_Root_G3
        is_expected.to match %r{oAIwOWZbwmSNuJ5Q3KjVSaLtx9zRSX8XAbjIho9OjIgrqJqpisXRAL34VOKa5Vt8}
      end
    end
  end

  context 'remove local trusted ca certificates' do
    let(:manifest) do
      <<~EOS
        ca_cert::ca { 'DigiCert_G5_TLS_ECC_SHA384_2021_CA1':
          ensure => 'absent',
        }

        ca_cert::ca { 'InCommon':
          ensure => 'absent',
        }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe file(trusted_ca_file_remote) do
      it { is_expected.not_to exist }
    end

    describe file(trusted_ca_file_text) do
      it { is_expected.not_to exist }
    end

    describe file(ca_certificates_bundle) do
      its(:content) do
        # DigiCert_G5_TLS_ECC_SHA384_2021_CA1
        is_expected.not_to match %r{IvZuhDckSAkMNGICMQD4lvGyMGMQirgiqAaMdybUTpcDTLtRQPKiGVZOoSaRtq8o}
        # InCommon
        is_expected.not_to match %r{kGGmSavOPN/mymTugmU5RZUWukEGAJi6DFZh5MbGhgHPZqkiKQLWPc/EKo2Z3vsJ}
        # DigiCert_Global_Root_G3
        is_expected.to match %r{oAIwOWZbwmSNuJ5Q3KjVSaLtx9zRSX8XAbjIho9OjIgrqJqpisXRAL34VOKa5Vt8}
      end
    end
  end
end
