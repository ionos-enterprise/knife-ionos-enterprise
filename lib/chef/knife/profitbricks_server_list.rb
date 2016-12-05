require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksServerList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks server list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the datacenter containing the server',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      def run
        $stdout.sync = true
        server_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Cores', :bold),
          ui.color('RAM', :bold),
          ui.color('Availability Zone', :bold),
          ui.color('VM State', :bold),
          ui.color('Boot Volume', :bold),
          ui.color('Boot CDROM', :bold)
        ]
        connection

        ProfitBricks::Server.list(config[:datacenter_id]).each do |server|
          server_list << server.id
          server_list << server.properties['name']
          server_list << server.properties['cores'].to_s
          server_list << server.properties['ram'].to_s
          server_list << server.properties['availabilityZone']
          server_list << server.properties['vmState']
          server_list << (server.properties['bootVolume'] == nil ? '' : server.properties['bootVolume']['id'])
          server_list << (server.properties['bootCdrom'] == nil ? '' : server.properties['bootCdrom']['id'])
        end

        puts ui.list(server_list, :uneven_columns_across, 8)
      end
    end
  end
end
