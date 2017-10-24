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
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'Name of the server'

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
             description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created'

      option :nat,
             long: '--nat',
             boolean: true | false,
             description: 'Set to enable NAT on the NIC'

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id server_id lan), Chef::Config[:knife])

        print "#{ui.color('Creating nic...', :magenta)}"

        params = {
          name: Chef::Config[:knife][:name],
          ips: Chef::Config[:knife][:ips],
          dhcp: Chef::Config[:knife][:dhcp],
          lan: Chef::Config[:knife][:lan]
        }

        if Chef::Config[:knife][:nat]
          params[:nat] = Chef::Config[:knife][:nat]
        end

        connection
        nic = ProfitBricks::NIC.create(
          Chef::Config[:knife][:datacenter_id],
          Chef::Config[:knife][:server_id],
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
        puts "#{ui.color('NAT', :cyan)}: #{nic.properties['nat']}"

        puts 'done'
      end
    end
  end
end
