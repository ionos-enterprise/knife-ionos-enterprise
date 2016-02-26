require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeDetach < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume detach VOLUME_UUID [VOLUME_UUID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_UUID',
             long: '--datacenter-id DATACENTER_UUID',
             description: 'The UUID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      option :server_id,
             short: '-S SERVER_UUID',
             long: '--server-id SERVER_UUID',
             description: 'The UUID of the server',
             required: true

      def run
        connection
        @name_args.each do |volume_id|
          begin
            volume = ProfitBricks::Volume.get(config[:datacenter_id], nil, volume_id)
          rescue Excon::Errors::NotFound
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          msg_pair('ID', volume.id)
          msg_pair('Name', volume.properties['name'])
          msg_pair('Size', volume.properties['size'])
          msg_pair('Bus', volume.properties['bus'])
          msg_pair('Device Number', volume.properties['deviceNumber'])

          confirm('Do you really want to detach this volume')

          volume.detach(config[:server_id])
          ui.msg("Detaching volume #{volume_id} from server")
        end
      end
    end
  end
end
