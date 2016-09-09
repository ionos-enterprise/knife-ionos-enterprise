require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksServerCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks server create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the virtual datacenter',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the server',
             required: true

      option :cores,
             short: '-C CORES',
             long: '--cores CORES',
             description: 'The number of processor cores',
             required: true

      option :cpufamily,
             short: '-f CPU_FAMILY',
             long: '--cpu-family CPU_FAMILY',
             description: 'The family of the CPU (INTEL_XEON or AMD_OPTERON)',
             default: 'AMD_OPTERON' 

      option :ram,
             short: '-r RAM',
             long: '--ram RAM',
             description: 'The amount of RAM in MB',
             required: true

      option :availabilityzone,
             short: '-a AVAILABILITY_ZONE',
             long: '--availability-zone AVAILABILITY_ZONE',
             description: 'The availability zone of the server',
             default: 'AUTO'

      option :bootvolume,
             long: '--boot-volume VOLUME_ID',
             description: 'Reference to a volume used for booting'

      option :bootcdrom,
             long: '--boot-cdrom CDROM_ID',
             description: 'Reference to a CD-ROM used for booting'

      def run
        $stdout.sync = true

        print "#{ui.color('Creating server...', :magenta)}"
        params = {
          name: config[:name],
          cores: config[:cores],
          cpuFamily: config[:cpufamily],
          ram: config[:ram],
          availabilityZone: config[:availabilityzone],
          bootVolume: config[:bootvolume],
          bootCdrom: config[:bootcdrom]
        }

        connection
        server = ProfitBricks::Server.create(
          config[:datacenter_id],
          params.compact
        )

        dot = ui.color('.', :magenta)
        server.wait_for { print dot; ready? }
        server.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{server.id}"
        puts "#{ui.color('Name', :cyan)}: #{server.properties['name']}"
        puts "#{ui.color('Cores', :cyan)}: #{server.properties['cores']}"
        puts "#{ui.color('CPU Family', :cyan)}: #{server.properties['cpuFamily']}"
        puts "#{ui.color('Ram', :cyan)}: #{server.properties['ram']}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{server.properties['availabilityZone']}"
        puts "#{ui.color('Boot Volume', :cyan)}: #{server.properties['bootVolume']}"
        puts "#{ui.color('Boot CDROM', :cyan)}: #{server.properties['bootCdrom']}"

        puts 'done'
      end
    end
  end
end
