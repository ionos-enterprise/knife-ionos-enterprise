require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksLanList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks lan list (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      def run
        $stdout.sync = true
        lan_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Public', :bold),
        ]
        connection

        ProfitBricks::LAN.list(Chef::Config[:knife][:datacenter_id]).each do |lan|
          lan_list << lan.id
          lan_list << lan.properties['name']
          lan_list << lan.properties['public'].to_s
        end

        puts ui.list(lan_list, :uneven_columns_across, 3)
      end
    end
  end
end
