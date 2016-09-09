require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksCompositeServerCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks composite server create (options)'

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
             description: 'The family of processor cores (INTEL_XEON or AMD_OPTERON)',
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

      option :volumename,
             long: '--volume-name NAME',
             description: 'Name of the volume'

      option :size,
             short: '-S SIZE',
             long: '--size SIZE',
             description: 'The size of the volume in GB',
             required: true

      option :bus,
             short: '-b BUS',
             long: '--bus BUS',
             description: 'The bus type of the volume (VIRTIO or IDE)'

      option :image,
             short: '-N ID',
             long: '--image ID',
             description: 'The image or snapshot ID'

      option :type,
             short: '-t TYPE',
             long: '--type TYPE',
             description: 'The disk type (HDD or SSD)',
             required: true

      option :licencetype,
             short: '-l LICENCE',
             long: '--licence-type LICENCE',
             description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :imagepassword,
             short: '-P PASSWORD',
             long: '--image-password PASSWORD',
             description: 'The password set on the image for the "root" or "Administrator" user'

      option :sshkeys,
             short: '-K SSHKEY[,SSHKEY,...]',
             long: '--ssh-keys SSHKEY1,SSHKEY2,...',
             description: 'A list of public SSH keys to include',
             proc: proc { |sshkeys| sshkeys.split(',') }

      option :nicname,
             long: '--nic-name NAME',
             description: 'Name of the NIC'

      option :ips,
             short: '-i IP[,IP,...]',
             long: '--ips IP[,IP,...]',
             description: 'IPs assigned to the NIC',
             proc: proc { |ips| ips.split(',') }

      option :dhcp,
             short: '-h',
             long: '--dhcp',
             boolean: true | false,
             default: true,
             description: 'Set to false if you wish to disable DHCP'

      option :lan,
             short: '-L ID',
             long: '--lan ID',
             description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created',
             required: true

      def run
        $stdout.sync = true

        print "#{ui.color('Creating composite server...', :magenta)}"
        volume_params = {
          name: config[:volumename],
          size: config[:size],
          bus: config[:bus] || 'VIRTIO',
          image: config[:image],
          type: config[:type],
          licenceType: config[:licencetype]
        }

        if config[:sshkeys]
          volume_params[:sshKeys] = config[:sshkeys]
        end

        if config[:imagepassword]
          volume_params[:imagePassword] = config[:imagepassword]
        end

        nic_params = {
          name: config[:nicname],
          ips: config[:ips],
          dhcp: config[:dhcp],
          lan: config[:lan]
        }

        params = {
          name: config[:name],
          cores: config[:cores],
          cpuFamily: config[:cpufamily],
          ram: config[:ram],
          availabilityZone: config[:availabilityzone],
          volumes: [volume_params],
          nics: [nic_params]
        }

        connection
        server = ProfitBricks::Server.create(
          config[:datacenter_id],
          params.compact
        )

        dot = ui.color('.', :magenta)
        server.wait_for(300) { print dot; ready? }
        server.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{server.id}"
        puts "#{ui.color('Name', :cyan)}: #{server.properties['name']}"
        puts "#{ui.color('Cores', :cyan)}: #{server.properties['cores']}"
        puts "#{ui.color('CPU Family', :cyan)}: #{server.properties['cpuFamily']}"
        puts "#{ui.color('Ram', :cyan)}: #{server.properties['ram']}"
        puts "#{ui.color('Availability Zone', :cyan)}: #{server.properties['availabilityZone']}"

        puts 'done'
      end
    end
  end
end
