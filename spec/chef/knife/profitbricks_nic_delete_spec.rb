require 'spec_helper'
require 'profitbricks_nic_delete'

Chef::Knife::ProfitbricksNicDelete.load_deps

describe Chef::Knife::ProfitbricksNicDelete do
  subject { Chef::Knife::ProfitbricksNicDelete.new }

  before :each do
    subject.config[:yes] = true
    allow(subject).to receive(:puts)
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

    @nic = ProfitBricks::NIC.create(@datacenter.id, @server.id, lan: @lan.id)
    @nic.wait_for { ready? }

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    Chef::Config[:knife][:server_id] = @server.id
    subject.name_args = [@nic.id]
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
    it 'should delete a nic' do
      subject.run
    end
  end
end
