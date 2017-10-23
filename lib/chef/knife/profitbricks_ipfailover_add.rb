require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksFailoverAdd < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipfailover add (options)'

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
             description: 'IP to be added to IP failover group'

      option :nic_id,
             short: '-n',
             long: '--nic-id',
             description: 'NIC to be added to IP failover group'

      def run
        $stdout.sync = true
        validate_required_params(%i[datacenter_id lan_id ip nic_id], Chef::Config[:knife])

        connection

        lan = ProfitBricks::LAN.get(Chef::Config[:knife][:datacenter_id], Chef::Config[:knife][:lan_id])

        failover_ips = lan.properties[:ipFailover]
        failover_ips ||= []
        ip_failover = {}
        ip_failover['ip'] = Chef::Config[:knife][:ip]
        ip_failover['nicUuid'] = Chef::Config[:knife][:nic_id]

        failover_ips.push(ip_failover)

        lan.update(ipFailover: failover_ips)
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
