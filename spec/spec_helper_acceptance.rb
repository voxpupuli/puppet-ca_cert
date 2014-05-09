require 'beaker-rspec'

hosts.each do |host|
  install_package host, 'rubygems'
  on host, 'gem install puppet --no-ri --no-rdoc'
  on host, "mkdir -p #{host['distmoduledir']}"
end

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
