require 'spec_helper_acceptance'

describe 'ca_cert class' do
  context 'default parameters' do
    let(:pp) do
      <<-EOS
        include ::ca_cert
      EOS
    end

    it_behaves_like "an idempotent resource"
  end
end
