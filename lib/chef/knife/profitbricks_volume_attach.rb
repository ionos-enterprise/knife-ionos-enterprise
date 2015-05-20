require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeAttach < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume attach VOLUME_UUID [VOLUME_UUID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_UUID',
             long: '--datacenter-id DATACENTER_UUID',
             description: 'The UUID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_UUID',
             long: '--server-id SERVER_UUID',
             description: 'The UUID of the server'

      def run
        connection
        @name_args.each do |volume_id|
          volume = ProfitBricks::Volume.get(config[:datacenter_id], nil, volume_id)
          volume

          if volume.nil?
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          volume.attach(config[:server_id])
          ui.msg("Volume #{volume_id} attached to server")
        end
      end
    end
  end
end
