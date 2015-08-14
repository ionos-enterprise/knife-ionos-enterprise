require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksDatacenterList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks datacenter list'

      def run
        $stdout.sync = true
        datacenter_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Location', :bold),
          ui.color('Version', :bold)
        ]
        connection
        ProfitBricks::Datacenter.list.each do |datacenter|
          datacenter_list << datacenter.id
          datacenter_list << datacenter.properties['name']
          datacenter_list << (datacenter.properties['description'] == nil ? '' : datacenter.properties['description'])
          datacenter_list << datacenter.properties['location']
          datacenter_list << datacenter.properties['version'].to_s
        end

        puts ui.list(datacenter_list, :uneven_columns_across, 5)
      end
    end
  end
end
