$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'

RSpec.configure do |config|
  config.before(:each) do
    Chef::Config.reset
    { :profitbricks_username => 'farid.shah@profitbricks.com',
      :profitbricks_password => 'spc2015',
      :profitbricks_url => 'https://spc.profitbricks.com'
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end
  end
end
