require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksLocationList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks location list'

      def run
        $stdout.sync = true
        location_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold)
        ]
        connection
        ProfitBricks::Location.list.each do |location|
          location_list << location.id
          location_list << location.properties['name']
        end

        puts ui.list(location_list, :uneven_columns_across, 2)
      end
    end
  end
end
