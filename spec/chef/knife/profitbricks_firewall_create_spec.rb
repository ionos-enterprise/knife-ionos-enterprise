require 'spec_helper'
require 'profitbricks_firewall_create'

Chef::Knife::ProfitbricksFirewallCreate.load_deps

describe Chef::Knife::ProfitbricksFirewallCreate do
  before :each do
    ProfitBricks.configure do |config|
      config.username = Chef::Config[:knife][:profitbricks_username]
      config.password = Chef::Config[:knife][:profitbricks_password]
      config.url = Chef::Config[:knife][:profitbricks_url]
      config.debug = Chef::Config[:knife][:profitbricks_debug] || false
      config.global_classes = false
    end
    @dcid = ''

    datacenter = ProfitBricks::Datacenter.create(name: 'Chef test',
                                                 description: 'Chef test datacenter',
                                                 location: 'us/las')

    datacenter.wait_for { ready? }
    @dcid = datacenter.id

    @server = ProfitBricks::Server.create(datacenter.id, name: 'Chef Test',
                                                         ram: 1024,
                                                         cores: 1,
                                                         availabilityZone: 'ZONE_1',
                                                         cpuFamily: 'INTEL_XEON')
    @server.wait_for { ready? }

    @nic = ProfitBricks::NIC.create(datacenter.id, @server.id, name: 'Chef Test',
                                                               dhcp: true,
                                                               lan: 1,
                                                               firewallActive: true,
                                                               nat: false)
    @nic.wait_for { ready? }

    allow(subject).to receive(:puts)
  end

  after :each do
    datacenter = ProfitBricks::Datacenter.get(@dcid)
    datacenter.delete
    datacenter.wait_for { ready? }
  end

  describe '#run' do
    it 'should output the column headers' do
      {
        datacenter_id: @dcid,
        server_id: @server.id,
        nic_id: @nic.id,
        name: 'Chef test',
        protocol: 'TCP',
        portrangestart: '22',
        portrangeend: 22
      }.each do |key, value|
        Chef::Config[:knife][key] = value
      end

      expect(subject).to receive(:puts).with('Name: Chef test')
      expect(subject).to receive(:puts).with('Protocol: TCP')
      expect(subject).to receive(:puts).with('Source MAC: ')
      expect(subject).to receive(:puts).with('Source IP: ')
      expect(subject).to receive(:puts).with('Target IP: ')
      expect(subject).to receive(:puts).with('Port Range Start: 22')
      expect(subject).to receive(:puts).with('Port Range End: 22')
      expect(subject).to receive(:puts).with('ICMP Type: ')
      expect(subject).to receive(:puts).with('ICMP Code: ')

      subject.run
    end
  end
end
