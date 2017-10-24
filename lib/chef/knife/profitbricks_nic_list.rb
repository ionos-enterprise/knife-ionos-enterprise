require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the datacenter containing the NIC',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server assigned the NIC'

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id server_id), Chef::Config[:knife])

        nic_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('IPs', :bold),
          ui.color('DHCP', :bold),
          ui.color('NAT', :bold),
          ui.color('LAN', :bold)
        ]
        connection

        ProfitBricks::NIC.list(Chef::Config[:knife][:datacenter_id], Chef::Config[:knife][:server_id]).each do |nic|
          nic_list << nic.id
          nic_list << nic.properties['name']
          nic_list << nic.properties['ips'].to_s
          nic_list << nic.properties['dhcp'].to_s
          nic_list << nic.properties['nat'].to_s
          nic_list << nic.properties['lan'].to_s
        end

        puts ui.list(nic_list, :uneven_columns_across, 6)
      end
    end
  end
end
