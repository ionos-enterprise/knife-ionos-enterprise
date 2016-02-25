require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksLanCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks lan create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_UUID',
             long: '--datacenter-id DATACENTER_UUID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the server'

      option :public,
             short: '-p',
             long: '--public',
             boolean: true,
             default: false,
             description: 'Boolean indicating if the LAN faces the public ' \
                          'Internet or not; defaults to false'

      def run
        $stdout.sync = true

        print "#{ui.color('Creating LAN...', :magenta)}"

        connection
        lan = ProfitBricks::LAN.create(
          config[:datacenter_id],
          name: config[:name],
          public: config[:public]
        )

        dot = ui.color('.', :magenta)
        lan.wait_for { print dot; ready? }
        lan.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{lan.id}"
        puts "#{ui.color('Name', :cyan)}: #{lan.properties['name']}"
        puts "#{ui.color('Public', :cyan)}: #{lan.properties['public']}"

        puts 'done'
      end
    end
  end
end
