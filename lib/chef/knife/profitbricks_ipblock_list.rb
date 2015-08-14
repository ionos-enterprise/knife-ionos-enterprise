require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksIpblockList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipblock list'

      def run
        $stdout.sync = true
        ipblock_list = [
          ui.color('ID', :bold),
          ui.color('Location', :bold),
          ui.color('IP Addresses', :bold),
        ]
        connection

        ProfitBricks::IPBlock.list.each do |ipblock|
          ipblock_list << ipblock.id
          ipblock_list << ipblock.properties['location']
          ipblock_list << ipblock.properties['ips'].join(", ").to_s
        end

        puts ui.list(ipblock_list, :uneven_columns_across, 3)
      end
    end
  end
end
