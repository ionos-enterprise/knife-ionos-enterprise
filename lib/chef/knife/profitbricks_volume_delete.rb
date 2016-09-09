require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume delete SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
             short: '-D ID',
             long: '--datacenter-id ID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      def run
        connection
        @name_args.each do |volume_id|
          begin
            volume = ProfitBricks::Volume.get(config[:datacenter_id], volume_id)
          rescue Excon::Errors::NotFound
            ui.error("Volume ID #{volume_id} not found. Skipping.")
            next
          end

          msg_pair('ID', volume.id)
          msg_pair('Name', volume.properties['name'])
          msg_pair('Size', volume.properties['size'])
          msg_pair('Bus', volume.properties['bus'])
          msg_pair('Image', volume.properties['image'])

          confirm('Do you really want to delete this volume')

          volume.delete
          ui.warn("Deleted volume #{volume.id}")
        end
      end
    end
  end
end
