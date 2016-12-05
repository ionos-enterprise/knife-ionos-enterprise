require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksFirewallList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks firewall list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server',
             required: true

      option :nic_id,
             short: '-N NIC_ID',
             long: '--nic-id NIC_ID',
             description: 'ID of the NIC',
             required: true

      def run
        $stdout.sync = true
        firewall_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Protocol', :bold),
          ui.color('Source MAC', :bold),
          ui.color('Source IP', :bold),
          ui.color('Target IP', :bold),
          ui.color('Port Range Start', :bold),
          ui.color('Port Range End', :bold),
          ui.color('ICMP Type', :bold),
          ui.color('ICMP CODE', :bold)
        ]
        connection

        ProfitBricks::Firewall.list(config[:datacenter_id], config[:server_id], config[:nic_id]).each do |firewall|
          firewall_list << firewall.id
          firewall_list << firewall.properties['name']
          firewall_list << firewall.properties['protocol'].to_s
          firewall_list << firewall.properties['sourceMac'].to_s
          firewall_list << firewall.properties['sourceIp'].to_s
          firewall_list << firewall.properties['targetIp'].to_s
          firewall_list << firewall.properties['portRangeStart'].to_s
          firewall_list << firewall.properties['portRangeEnd'].to_s
          firewall_list << firewall.properties['icmpType'].to_s
          firewall_list << firewall.properties['icmpCode'].to_s
        end

        puts ui.list(firewall_list, :uneven_columns_across, 10)
      end
    end
  end
end
