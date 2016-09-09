require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksNicCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks nic create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'Name of the server',
             required: true

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the NIC'

      option :ips,
             short: '-i IP[,IP,...]',
             long: '--ips IP[,IP,...]',
             description: 'IPs assigned to the NIC',
             proc: proc { |ips| ips.split(',') }

      option :dhcp,
             short: '-d',
             long: '--dhcp',
             boolean: true | false,
             default: true,
             description: 'Set to false if you wish to disable DHCP'

      option :lan,
             short: '-l ID',
             long: '--lan ID',
             description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created',
             required: true

      def run
        $stdout.sync = true

        print "#{ui.color('Creating nic...', :magenta)}"

        params = {
          name: config[:name],
          ips: config[:ips],
          dhcp: config[:dhcp],
          lan: config[:lan]
        }

        connection
        nic = ProfitBricks::NIC.create(
          config[:datacenter_id],
          config[:server_id],
          params.compact
        )

        dot = ui.color('.', :magenta)
        nic.wait_for { print dot; ready? }
        nic.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{nic.id}"
        puts "#{ui.color('Name', :cyan)}: #{nic.properties['name']}"
        puts "#{ui.color('IPs', :cyan)}: #{nic.properties['ips']}"
        puts "#{ui.color('DHCP', :cyan)}: #{nic.properties['dhcp']}"
        puts "#{ui.color('LAN', :cyan)}: #{nic.properties['lan']}"

        puts 'done'
      end
    end
  end
end
