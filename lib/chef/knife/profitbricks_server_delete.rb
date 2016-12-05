require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksServerDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks server delete SERVER_ID [SERVER_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      def run
        connection
        @name_args.each do |server_id|
          begin
            server = ProfitBricks::Server.get(config[:datacenter_id], server_id)
          rescue Excon::Errors::NotFound
            ui.error("Server ID #{server_id} not found. Skipping.")
            next
          end

          msg_pair('ID', server.id)
          msg_pair('Name', server.properties['name'])
          msg_pair('Cores', server.properties['cores'])
          msg_pair('RAM', server.properties['ram'])
          msg_pair('Availability Zone', server.properties['availabilityZone'])

          confirm('Do you really want to delete this server')

          server.delete
          ui.warn("Deleted server #{server.id}")
        end
      end
    end
  end
end
