require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksIpblockCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipblock create (options)'

      option :location,
             short: '-l LOCATION',
             long: '--location LOCATION',
             description: 'Location of the IP block (us/las, us/ewr, de/fra, de/fkb)'

      option :size,
             short: '-S INT',
             long: '--size INT',
             description: 'The number of IP addresses to reserve'

      def run
        $stdout.sync = true
        validate_required_params(%i(size location), Chef::Config[:knife])

        print "#{ui.color('Allocating IP block...', :magenta)}"

        connection
        ipblock = ProfitBricks::IPBlock.create(
          location: Chef::Config[:knife][:location],
          size: Chef::Config[:knife][:size]
        )

        dot = ui.color('.', :magenta)
        ipblock.wait_for { print dot; ready? }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{ipblock.id}"
        puts "#{ui.color('Location', :cyan)}: #{ipblock.properties['location']}"
        puts "#{ui.color('IP Addresses', :cyan)}: #{ipblock.properties['ips']}"
        @ipid = ipblock.id
        puts 'done'
      end
    end
  end
end
