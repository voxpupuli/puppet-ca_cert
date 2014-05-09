require 'spec_helper_acceptance'

describe 'ca_cert class', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
        class { 'ca_cert': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end
