require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksServerStart < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks server start SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      def run
        connection
        @name_args.each do |server_id|
          begin
            server = ProfitBricks::Server.get(Chef::Config[:knife][:datacenter_id], server_id)
          rescue Excon::Errors::NotFound
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end

          server.start
          ui.warn("Server #{server.id} is starting")
        end
      end
    end
  end
end
