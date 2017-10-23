require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksFailoverRemove < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipfailover remove (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :lan_id,
             short: '-l LAN_ID',
             long: '--lan-id LAN_ID',
             description: 'Lan ID'
      option :ip,
             short: '-i',
             long: '--ip',
             description: 'IP to be removed from IP failover group'

      option :nic_id,
             short: '-n',
             long: '--nic-id',
             description: 'NIC to be removed from IP failover group'

      def run
        $stdout.sync = true
        validate_required_params(%i[datacenter_id lan_id ip nic_id], Chef::Config[:knife])

        connection

        lan = ProfitBricks::LAN.get(Chef::Config[:knife][:datacenter_id], Chef::Config[:knife][:lan_id])

        ipfailover = lan.properties['ipFailover']

        ipfailover.each_with_index do |value, index|
          if value['nicUuid'] == Chef::Config[:knife][:nic_id] && value['ip'] == Chef::Config[:knife][:ip]
            ipfailover.delete_at(index)
          end
        end

        lan.update(ipFailover: ipfailover)
        lan.wait_for { ready? }
        lan.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{lan.id}"
        puts "#{ui.color('Name', :cyan)}: #{lan.properties['name']}"
        puts "#{ui.color('Public', :cyan)}: #{lan.properties['public']}"
        puts "#{ui.color('IP Failover', :cyan)}: #{lan.properties['ipFailover']}"

        puts 'done'
      end
    end
  end
end
