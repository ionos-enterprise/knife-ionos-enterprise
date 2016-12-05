require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksFirewallDelete < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks firewall delete FIREWALL_ID [FIREWALL_ID] (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'The ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'The ID of the server',
             required: true

      option :nic_id,
             short: '-N NIC_ID',
             long: '--nic-id NIC_ID',
             description: 'ID of the NIC',
             required: true

      def run
        connection
        @name_args.each do |firewall_id|
          begin
            firewall = ProfitBricks::Firewall.get(config[:datacenter_id],
                                                  config[:server_id],
                                                  config[:nic_id],
                                                  firewall_id)
          rescue Excon::Errors::NotFound
            ui.error("Firewall ID #{firewall_id} not found. Skipping.")
            next
          end

          msg_pair('ID', firewall.id)
          msg_pair('Name', firewall.properties['name'])
          msg_pair('Protocol', firewall.properties['protocol'])
          msg_pair('Source MAC', firewall.properties['sourceMac'])
          msg_pair('Source IP', firewall.properties['sourceIp'])
          msg_pair('Target IP', firewall.properties['targetIp'])
          msg_pair('Port Range Start', firewall.properties['portRangeStart'])
          msg_pair('Port Range End', firewall.properties['portRangeEnd'])
          msg_pair('ICMP Type', firewall.properties['icmpType'])
          msg_pair('ICMP Code', firewall.properties['icmpCode'])

          confirm('Do you really want to delete this firewall rule')

          firewall.delete
          ui.warn("Deleted firewall rule #{firewall.id}")
        end
      end
    end
  end
end
