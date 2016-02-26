require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksLanDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks lan delete LAN_UUID [LAN_UUID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_UUID',
             long: '--datacenter-id DATACENTER_UUID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      def run
        connection
        @name_args.each do |lan_id|
          begin
            lan = ProfitBricks::LAN.get(config[:datacenter_id], lan_id)
          rescue Excon::Errors::NotFound
            ui.error("Lan ID #{lan_id} not found. Skipping.")
            next
          end

          msg_pair('ID', lan.id)
          msg_pair('Name', lan.properties['name'])
          msg_pair('Public', lan.properties['public'].to_s)

          confirm('Do you really want to delete this LAN')

          lan.delete
          ui.warn("Deleted LAN #{lan.id}")
        end
      end
    end
  end
end
