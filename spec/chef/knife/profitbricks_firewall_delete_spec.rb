require 'spec_helper'
require 'profitbricks_firewall_delete'

Chef::Knife::ProfitbricksFirewallDelete.load_deps

describe Chef::Knife::ProfitbricksFirewallDelete do
  subject { Chef::Knife::ProfitbricksFirewallDelete.new }

  before :each do
    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:confirm)

    subject.config[:yes] = true

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

    @fw = ProfitBricks::Firewall.create(datacenter.id, @server.id, @nic.id,
                                        name: 'SSH',
                                        protocol: 'TCP',
                                        sourceMac: '01:23:45:67:89:00',
                                        sourceIp: nil,
                                        targetIp: nil,
                                        portRangeStart: 22,
                                        portRangeEnd: 22,
                                        icmpType: nil,
                                        icmpCode: nil)

    @fw.wait_for { ready? }
  end

  after :each do
    datacenter = ProfitBricks::Datacenter.get(@dcid)
    datacenter.delete
    datacenter.wait_for { ready? }
  end

  describe '#run' do
    it 'should delete a firewall rule' do
      subject.name_args = [@fw.id]

      {
        datacenter_id: @dcid,
        server_id: @server.id,
        nic_id: @nic.id
      }.each do |key, value|
        Chef::Config[:knife][key] = value
      end

      expect(subject).to receive(:puts).with('Name: SSH')
      expect(subject).to receive(:puts).with('Protocol: TCP')
      expect(subject).to receive(:puts).with('Source MAC: 01:23:45:67:89:00')
      expect(subject).to receive(:puts).with('Port Range Start: 22')
      expect(subject).to receive(:puts).with('Port Range End: 22')
      subject.run
    end
  end
end
