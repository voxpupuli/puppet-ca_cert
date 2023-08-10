# frozen_string_literal: true

require 'puppet_litmus'
PuppetLitmus.configure!

require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))

shared_examples 'an idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, catch_changes: true)
  end
end
