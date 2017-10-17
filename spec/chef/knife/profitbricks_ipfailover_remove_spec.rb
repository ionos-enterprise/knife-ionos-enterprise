require 'spec_helper'
require 'profitbricks_ipfailover_remove'

Chef::Knife::ProfitbricksFailoverRemove.load_deps

describe Chef::Knife::ProfitbricksFailoverRemove do
  subject { Chef::Knife::ProfitbricksFailoverRemove.new }

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

    @server = ProfitBricks::Server.create(@datacenter.id, name: 'Chef Test',
                                                          ram: 1024,
                                                          cores: 1,
                                                          availabilityZone: 'ZONE_1',
                                                          cpuFamily: 'INTEL_XEON')
    @server.wait_for { ready? }

    @lan = ProfitBricks::LAN.create(@datacenter.id, name: 'Chef Test',
                                                    public: 'true')
    @lan.wait_for { ready? }

    @nic = ProfitBricks::NIC.create(@datacenter.id, @server.id, lan: @lan.id)
    @nic.wait_for { ready? }

    @ip_block = ProfitBricks::IPBlock.reserve(location: 'us/las',
                                              size: 1)
    @ip_block.wait_for { ready? }
    @nic.update(ips: [@ip_block.properties['ips'][0]])
    @nic.wait_for { ready? }
    ip_failover = {}
    ip_failover['ip'] = @ip_block.properties['ips'][0]
    ip_failover['nicUuid'] = @nic.id

    @lan.update(ipFailover: [ip_failover])
    @lan.wait_for { ready? }
    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    Chef::Config[:knife][:lan_id] = @lan.id
    Chef::Config[:knife][:ip] = @ip_block.properties['ips'][0]
    Chef::Config[:knife][:nic_id] = @nic.id

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
    @ip_block.release
    @ip_block.wait_for { ready? }
  end

  describe '#run' do
    it 'should renive ip failover' do
      expect(subject).to receive(:puts).with('Name: Chef Test')
      expect(subject).to receive(:puts).with('Public: true')
      subject.run
    end
  end
end
