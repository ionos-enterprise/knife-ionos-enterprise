require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksIpblockCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks ipblock create (options)'

      option :location,
             short: '-l LOCATION',
             long: '--location LOCATION',
             description: 'Location of the IP block (us/las, de/fra, de/fkb)',
             required: true

      option :size,
             short: '-S INT',
             long: '--size INT',
             description: 'The number of IP addresses to reserve',
             required: true

      def run
        $stdout.sync = true

        print "#{ui.color('Allocating IP block...', :magenta)}"

        connection
        ipblock = ProfitBricks::IPBlock.create(
          location: config[:location],
          size: config[:size]
        )

        dot = ui.color('.', :magenta)
        ipblock.wait_for { print dot; ready? }

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{ipblock.id}"
        puts "#{ui.color('Location', :cyan)}: #{ipblock.properties['location']}"
        puts "#{ui.color('IP Addresses', :cyan)}: #{ipblock.properties['ips']}"

        puts 'done'
      end
    end
  end
end
