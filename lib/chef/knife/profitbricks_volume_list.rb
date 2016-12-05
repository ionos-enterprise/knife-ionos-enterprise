require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the virtul data center containing the volume',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server',
             required: false

      def run
        $stdout.sync = true
        volume_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Size', :bold),
          ui.color('Bus', :bold),
          ui.color('Image', :bold),
          ui.color('Type', :bold),
          ui.color('Zone', :bold),
          ui.color('Device Number', :bold)
        ]

        connection
        if defined?(config[:server_id]) && config[:server_id]
          server = ProfitBricks::Server.get(config[:datacenter_id], config[:server_id])
          server.list_volumes.each do |volume|
            volume_list << volume.id
            volume_list << volume.properties['name']
            volume_list << volume.properties['size'].to_s
            volume_list << volume.properties['bus']
            volume_list << volume.properties['image']
            volume_list << volume.properties['type']
            volume_list << volume.properties['availabilityZone']
            volume_list << volume.properties['deviceNumber'].to_s
          end 
        else
          ProfitBricks::Volume.list(config[:datacenter_id]).each do |volume|
            volume_list << volume.id
            volume_list << volume.properties['name']
            volume_list << volume.properties['size'].to_s
            volume_list << volume.properties['bus']
            volume_list << volume.properties['image']
            volume_list << volume.properties['type']
            volume_list << volume.properties['availabilityZone']
            volume_list << volume.properties['deviceNumber'].to_s
          end
        end

        puts ui.list(volume_list, :uneven_columns_across, 8)
      end
    end
  end
end
