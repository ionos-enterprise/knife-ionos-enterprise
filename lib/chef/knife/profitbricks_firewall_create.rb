require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksFirewallCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks firewall create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'ID of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :server_id,
             short: '-S SERVER_ID',
             long: '--server-id SERVER_ID',
             description: 'ID of the server'

      option :nic_id,
             short: '-N NIC_ID',
             long: '--nic-id NIC_ID',
             description: 'ID of the NIC'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the NIC'

      option :protocol,
             short: '-P PROTOCOL',
             long: '--protocol PROTOCOL',
             default: 'TCP',
             description: 'The protocol of the firewall rule (TCP, UDP, ICMP,' \
                          ' ANY)'

      option :sourcemac,
             short: '-m MAC',
             long: '--source-mac MAC',
             description: 'Only traffic originating from the respective MAC' \
                          ' address is allowed'

      option :sourceip,
             short: '-I IP',
             long: '--source-ip IP',
             description: 'Only traffic originating from the respective IPv4' \
                          ' address is allowed; null allows all source IPs'

      option :targetip,
             long: '--target-ip IP',
             description: 'In case the target NIC has multiple IP addresses,' \
                          ' only traffic directed to the respective IP' \
                          ' address of the NIC is allowed; null value allows' \
                          ' all target IPs'

      option :portrangestart,
             short: '-p PORT',
             long: '--port-range-start PORT',
             description: 'Defines the start range of the allowed port(s)'

      option :portrangeend,
             short: '-t PORT',
             long: '--port-range-end PORT',
             description: 'Defines the end range of the allowed port(s)'

      option :icmptype,
             long: '--icmp-type INT',
             description: 'Defines the allowed type (from 0 to 254) if the' \
                          ' protocol ICMP is chosen; null allows all types'

      option :icmpcode,
             long: '--icmp-code INT',
             description: 'Defines the allowed code (from 0 to 254) if the' \
                          ' protocol ICMP is chosen; null allows all codes'

      def run
        $stdout.sync = true

        validate_required_params(%i(datacenter_id server_id nic_id protocol) , Chef::Config[:knife])

        print "#{ui.color('Creating firewall...', :magenta)}"

        params = {
          name: Chef::Config[:knife][:name],
          protocol: Chef::Config[:knife][:protocol],
          sourceMac: Chef::Config[:knife][:sourcemac],
          sourceIp: Chef::Config[:knife][:sourceip],
          targetIp: Chef::Config[:knife][:targetip],
          portRangeStart: Chef::Config[:knife][:portrangestart],
          portRangeEnd: Chef::Config[:knife][:portrangeend],
          icmpType: Chef::Config[:knife][:icmptype],
          icmpCode: Chef::Config[:knife][:icmpcode]
        }

        connection
        firewall = ProfitBricks::Firewall.create(
          Chef::Config[:knife][:datacenter_id],
          Chef::Config[:knife][:server_id],
          Chef::Config[:knife][:nic_id],
          params.compact
        )

        dot = ui.color('.', :magenta)
        firewall.wait_for { print dot; ready? }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{firewall.id}"
        puts "#{ui.color('Name', :cyan)}: #{firewall.properties['name']}"
        puts "#{ui.color('Protocol', :cyan)}: #{firewall.properties['protocol']}"
        puts "#{ui.color('Source MAC', :cyan)}: #{firewall.properties['sourceMac']}"
        puts "#{ui.color('Source IP', :cyan)}: #{firewall.properties['sourceIp']}"
        puts "#{ui.color('Target IP', :cyan)}: #{firewall.properties['targetIp']}"
        puts "#{ui.color('Port Range Start', :cyan)}: #{firewall.properties['portRangeStart']}"
        puts "#{ui.color('Port Range End', :cyan)}: #{firewall.properties['portRangeEnd']}"
        puts "#{ui.color('ICMP Type', :cyan)}: #{firewall.properties['icmpType']}"
        puts "#{ui.color('ICMP Code', :cyan)}: #{firewall.properties['icmpCode']}"
        puts 'done'
      end
    end
  end
end
