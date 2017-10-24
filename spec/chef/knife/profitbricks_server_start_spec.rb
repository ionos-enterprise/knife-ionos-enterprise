require 'spec_helper'
require 'profitbricks_server_start'

Chef::Knife::ProfitbricksServerStart.load_deps

describe Chef::Knife::ProfitbricksServerStart do
  subject { Chef::Knife::ProfitbricksServerStart.new }

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

    @server.stop
    @server.wait_for { ready? }

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    subject.name_args = [@server.id]

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
    it 'should output the column headers' do
      subject.run
    end
  end
end
