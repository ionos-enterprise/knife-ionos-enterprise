require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksDatacenterCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks datacenter create (options)'

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the data center'

      option :description,
             short: '-D DESCRIPTION',
             long: '--description DESCRIPTION',
             description: 'Description of the data center'

      option :location,
             short: '-l LOCATION',
             long: '--location LOCATION',
             description: 'Location of the data center',
             proc: proc { |location| Chef::Config[:knife][:location] = location }

      def run
        $stdout.sync = true

        print "#{ui.color('Creating data center...', :magenta)}"

        connection
        datacenter = ProfitBricks::Datacenter.create(
          name: config[:name],
          description: config[:description],
          location: config[:location]
        )

        dot = ui.color('.', :magenta)
        datacenter.wait_for { print dot; ready? }
        datacenter.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{datacenter.id}"
        puts "#{ui.color('Name', :cyan)}: #{datacenter.properties['name']}"
        puts "#{ui.color('Description', :cyan)}: #{datacenter.properties['description']}"
        puts "#{ui.color('Location', :cyan)}: #{datacenter.properties['location']}"
        puts 'done'
      end
    end
  end
end
