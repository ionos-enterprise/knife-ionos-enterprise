require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksDatacenterDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks datacenter delete DATACENTER_ID' \
             ' [DATACENTER_ID] (options)'

      option :purge,
             short: '-p',
             long: '--purge',
             boolean: true,
             default: false,
             description: 'Recursively delete the datacenter and all' \
                          ' corresponding resources under the datacenter.'

      def run
        connection
        @name_args.each do |datacenter_id|
          begin
            datacenter = ProfitBricks::Datacenter.get(datacenter_id)
          rescue Excon::Errors::NotFound
            ui.error("Data center ID #{datacenter_id} not found. Skipping.")
            next
          end

          msg_pair('ID', datacenter.id)
          msg_pair('Name', datacenter.properties['name'])
          msg_pair('Description', datacenter.properties['description'])
          msg_pair('Location', datacenter.properties['location'])
          msg_pair('Version', datacenter.properties['version'])

          puts "\n"
          confirm('Do you really want to delete this data center')

          datacenter.delete
          ui.warn("Deleted data center #{datacenter.id}")
        end
      end
    end
  end
end
