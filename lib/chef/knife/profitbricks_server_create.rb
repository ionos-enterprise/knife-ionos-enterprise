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
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the server'

      option :cores,
             short: '-C CORES',
             long: '--cores CORES',
             description: 'The number of processor cores'

      option :cpufamily,
             short: '-f CPU_FAMILY',
             long: '--cpu-family CPU_FAMILY',
             description: 'The family of the CPU (INTEL_XEON or AMD_OPTERON)',
             default: 'AMD_OPTERON'

      option :ram,
             short: '-r RAM',
             long: '--ram RAM',
             description: 'The amount of RAM in MB'

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
        validate_required_params(%i(datacenter_id name cores ram), Chef::Config[:knife])

        print "#{ui.color('Creating server...', :magenta)}"
        params = {
          name: Chef::Config[:knife][:name],
          cores: Chef::Config[:knife][:cores],
          cpuFamily: Chef::Config[:knife][:cpufamily],
          ram: Chef::Config[:knife][:ram],
          availabilityZone: Chef::Config[:knife][:availabilityzone]
        }

        if Chef::Config[:knife][:bootcdrom]
          params[:bootCdrom] = { id: Chef::Config[:knife][:bootcdrom] }
        end

        if Chef::Config[:knife][:bootvolume]
          params[:bootVolume] = { id: Chef::Config[:knife][:bootvolume] }
        end

        connection
        server = ProfitBricks::Server.create(
          Chef::Config[:knife][:datacenter_id],
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
