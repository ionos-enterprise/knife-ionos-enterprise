require 'spec_helper'
require 'profitbricks_server_create'

Chef::Knife::ProfitbricksServerCreate.load_deps

describe Chef::Knife::ProfitbricksServerCreate do
  subject { Chef::Knife::ProfitbricksServerCreate.new }

  before :each do
    {
      name: 'Chef Test',
      public: 'true'
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

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
    Chef::Config[:knife][:cores] = 2
    Chef::Config[:knife][:ram] = 2048
    Chef::Config[:knife][:name] = 'Chef Test'

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

    @datacenter.delete
    @datacenter.wait_for { ready? }
  end

  describe '#run' do
    it 'should create a server' do
      expect(subject).to receive(:puts).with('Name: Chef Test')
      expect(subject).to receive(:puts).with('Cores: 2')
      expect(subject).to receive(:puts).with('Ram: 2048')
      subject.run
    end
  end
end
