require 'spec_helper'
require 'profitbricks_nic_create'

Chef::Knife::ProfitbricksNicCreate.load_deps

describe Chef::Knife::ProfitbricksNicCreate do
  subject { Chef::Knife::ProfitbricksNicCreate.new }

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

    @server = ProfitBricks::Server.create(@datacenter.id, name: 'Chef Test',
                                                          ram: 1024,
                                                          cores: 1,
                                                          availabilityZone: 'ZONE_1',
                                                          cpuFamily: 'INTEL_XEON')
    @server.wait_for { ready? }

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    Chef::Config[:knife][:server_id] = @server.id
    Chef::Config[:knife][:lan] = @lan.id
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
    it 'should create a nic' do
      expect(subject).to receive(:puts).with('Name: Chef Test')
      expect(subject).to receive(:puts).with('DHCP: true')
      expect(subject).to receive(:puts).with('LAN: 1')
      expect(subject).to receive(:puts).with('NAT: false')
      subject.run
    end
  end
end
