require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksIpblockDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipblock delete IPBLOCK_ID [IPBLOCK_ID]'

      def run
        connection
        @name_args.each do |ipblock_id|
          begin
            ipblock = ProfitBricks::IPBlock.get(ipblock_id)
          rescue Excon::Errors::NotFound
            ui.error("IP block ID #{ipblock_id} not found. Skipping.")
            next
          end

          msg_pair('ID', ipblock.id)
          msg_pair('Location', ipblock.properties['location'])
          msg_pair('IP Addresses', ipblock.properties['ips'])

          confirm('Do you really want to delete this IP block')

          ipblock.delete
          ui.warn("Released IP block #{ipblock.id}")
        end
      end
    end
  end
end
