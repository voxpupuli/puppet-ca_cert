require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

UNSUPPORTED_PLATFORMS = ['windows', 'aix', 'Solaris', 'BSD']

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation

  c.before :suite do
    puppet_module_install(:source => proj_root, :module_name => 'ca_cert')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end

shared_examples "an idempotent resource" do
  it 'should apply with no errors' do
    apply_manifest(pp, :catch_failures => true)
  end

  it 'should apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, :catch_changes => true)
  end
end
