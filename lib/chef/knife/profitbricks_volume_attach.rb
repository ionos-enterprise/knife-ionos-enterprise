require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeAttach < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume attach VOLUME_ID [VOLUME_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server'

      def run
        validate_required_params(%i(datacenter_id server_id), Chef::Config[:knife])

        connection
        @name_args.each do |volume_id|
          volume = ProfitBricks::Volume.get(Chef::Config[:knife][:datacenter_id], nil, volume_id)

          if volume.nil?
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          volume.attach(Chef::Config[:knife][:server_id])
          ui.msg("Volume #{volume_id} attached to server")
        end
      end
    end
  end
end
