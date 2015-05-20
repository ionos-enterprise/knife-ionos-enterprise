require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic delete NIC_UUID [NIC_UUID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_UUID',
             long: '--datacenter-id DATACENTER_UUID',
             description: 'The UUID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_UUID',
             long: '--server-id SERVER_UUID',
             description: 'The UUID of the server assigned the NIC'

      def run
        connection
        @name_args.each do |nic_id|
          begin
            nic = ProfitBricks::NIC.get(config[:datacenter_id], config[:server_id], nic_id)
          rescue Excon::Errors::NotFound
            ui.error("NIC ID #{nic_id} not found. Skipping.")
            next
          end

          msg_pair('ID', nic.id)
          msg_pair('Name', nic.properties['name'])
          msg_pair('IPs', nic.properties['cores'])
          msg_pair('DHCP', nic.properties['ram'])
          msg_pair('LAN', nic.properties['availabilityZone'])

          confirm('Do you really want to delete this NIC')

          nic.delete
          ui.warn("Deleted nic #{nic.id}")
        end
      end
    end
  end
end
