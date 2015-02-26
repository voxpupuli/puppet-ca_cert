require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.before :each do
    Puppet.settings[:strict_variables]=true
  end
end
