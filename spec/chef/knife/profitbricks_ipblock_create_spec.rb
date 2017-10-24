require 'spec_helper'
require 'profitbricks_ipblock_create'

Chef::Knife::ProfitbricksIpblockCreate.load_deps

describe Chef::Knife::ProfitbricksIpblockCreate do
  subject { Chef::Knife::ProfitbricksIpblockCreate.new }

  before :each do
    {
      location: 'us/las',
      size: 1
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end
    allow(subject).to receive(:puts)
  end

  after :each do
    ProfitBricks.configure do |config|
      config.username = Chef::Config[:knife][:profitbricks_username]
      config.password = Chef::Config[:knife][:profitbricks_password]
      config.url = Chef::Config[:knife][:profitbricks_url]
      config.debug = Chef::Config[:knife][:profitbricks_debug] || false
      config.global_classes = false
    end

    ipid = subject.instance_variable_get :@ipid
    ip = ProfitBricks::IPBlock.get(ipid)
    ip.release
  end

  describe '#run' do
    it 'should reserve a IP block' do
      expect(subject).to receive(:puts).with('done')
      subject.run
    end
  end
end
