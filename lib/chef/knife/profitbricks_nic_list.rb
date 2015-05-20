require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_UUID',
             long: '--datacenter-id DATACENTER_UUID',
             description: 'The UUID of the datacenter containing the NIC',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_UUID',
             long: '--server-id SERVER_UUID',
             description: 'The UUID of the server assigned the NIC'

      def run
        $stdout.sync = true
        nic_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('IPs', :bold),
          ui.color('DHCP', :bold),
          ui.color('LAN', :bold)
        ]
        connection

        ProfitBricks::NIC.list(config[:datacenter_id], config[:server_id]).each do |nic|
          nic_list << nic.id
          nic_list << nic.properties['name']
          nic_list << nic.properties['ips'].to_s
          nic_list << nic.properties['dhcp'].to_s
          nic_list << nic.properties['lan'].to_s
        end

        puts ui.list(nic_list, :columns_across, 5)
      end
    end
  end
end
