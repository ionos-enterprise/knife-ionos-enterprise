require 'spec_helper'
require 'profitbricks_lan_list'

Chef::Knife::ProfitbricksLanList.load_deps

describe Chef::Knife::ProfitbricksLanList do
  let(:lan_list) { Chef::Knife::ProfitbricksLanList.new }

  before :each do
    ProfitBricks.configure do |config|
      config.username = Chef::Config[:knife][:profitbricks_username]
      config.password = Chef::Config[:knife][:profitbricks_password]
      config.url = Chef::Config[:knife][:profitbricks_url]
      config.debug = Chef::Config[:knife][:profitbricks_debug] || false
      config.global_classes = false
    end

    @datacenter = ProfitBricks::Datacenter.create(name: 'Chef test',
                                                  description: 'Chef test datacenter',
                                                  location: 'us/las')
    @datacenter.wait_for { ready? }

    @lan = ProfitBricks::LAN.create(@datacenter.id, name: 'Chef Test',
                                                    public: 'true')
    @lan.wait_for { ready? }

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    allow(lan_list).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(lan_list).to receive(:puts).with(/^ID\s+Name\s+Public\s*$/)
      lan_list.run
    end
  end
end
