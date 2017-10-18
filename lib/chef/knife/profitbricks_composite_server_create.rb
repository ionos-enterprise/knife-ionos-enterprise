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
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: '(required) Name of the server'

      option :cores,
             short: '-C CORES',
             long: '--cores CORES',
             description: '(required) The number of processor cores'

      option :cpufamily,
             short: '-f CPU_FAMILY',
             long: '--cpu-family CPU_FAMILY',
             description: 'The family of processor cores (INTEL_XEON or AMD_OPTERON)',
             default: 'AMD_OPTERON'

      option :ram,
             short: '-r RAM',
             long: '--ram RAM',
             description: '(required) The amount of RAM in MB'

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
             description: '(required) The size of the volume in GB'

      option :bus,
             short: '-b BUS',
             long: '--bus BUS',
             description: 'The bus type of the volume (VIRTIO or IDE)'

      option :image,
             short: '-N ID',
             long: '--image ID',
             description: '(required) The image or snapshot ID'

      option :imagealias,
             long: '--imagealias IMAGE_ALIAS',
             description: '(required) The image alias'

      option :type,
             short: '-t TYPE',
             long: '--type TYPE',
             description: '(required) The disk type (HDD or SSD)'

      option :licencetype,
             short: '-l LICENCE',
             long: '--licence-type LICENCE',
             description: 'The licence type of the volume (LINUX, WINDOWS, WINDOWS2016, UNKNOWN, OTHER)'

      option :imagepassword,
             short: '-P PASSWORD',
             long: '--image-password PASSWORD',
             description: 'The password set on the image for the "root" or "Administrator" user'

      option :volume_availability_zone,
             short: '-Z AVAILABILITY_ZONE',
             long: '--volume-availability-zone AVAILABILITY_ZONE',
             description: 'The volume availability zone of the server'

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
             description: '(required) Set to false if you wish to disable DHCP'

      option :lan,
             short: '-L ID',
             long: '--lan ID',
             description: 'The LAN ID the NIC will reside on; if the LAN ID does not exist it will be created'

      option :nat,
             long: '--nat',
             description: 'Set to enable NAT on the NIC'

      def run
        $stdout.sync = true

        validate_required_params(%i[datacenter_id name cores ram size type dhcp lan], Chef::Config[:knife])

        if !Chef::Config[:knife][:image] && !Chef::Config[:knife][:imagealias]
          ui.error("Either 'image' or 'imagealias' parameter must be provided")
          exit(1)
        end

        if !Chef::Config[:knife][:sshkeys] && !Chef::Config[:knife][:imagepassword]
          ui.error("Either 'imagepassword' or 'sshkeys' parameter must be provided")
          exit(1)
        end
        
        print ui.color('Creating composite server...', :magenta).to_s
        volume_params = {
          name: Chef::Config[:knife][:volumename],
          size: Chef::Config[:knife][:size],
          bus: Chef::Config[:knife][:bus] || 'VIRTIO',
          image: Chef::Config[:knife][:image],
          type: Chef::Config[:knife][:type],
          licenceType: Chef::Config[:knife][:licencetype]
        }

        if Chef::Config[:knife][:image]
          volume_params['image'] = Chef::Config[:knife][:image]
        end

        if Chef::Config[:knife][:imagealias]
          volume_params['imageAlias'] = Chef::Config[:knife][:imagealias]
        end

        if Chef::Config[:knife][:sshkeys]
          volume_params[:sshKeys] = Chef::Config[:knife][:sshkeys]
        end

        if Chef::Config[:knife][:imagepassword]
          volume_params[:imagePassword] = Chef::Config[:knife][:imagepassword]
        end

        if config[:volume_availability_zone]
          volume_params[:availabilityZone] = Chef::Config[:knife][:volume_availability_zone]
        end

        nic_params = {
          name: Chef::Config[:knife][:nicname],
          ips: Chef::Config[:knife][:ips],
          dhcp: Chef::Config[:knife][:dhcp],
          lan: Chef::Config[:knife][:lan]
        }

        nic_params[:nat] = Chef::Config[:knife][:nat] if config[:nat]

        params = {
          name: Chef::Config[:knife][:name],
          cores: Chef::Config[:knife][:cores],
          cpuFamily: Chef::Config[:knife][:cpufamily],
          ram: Chef::Config[:knife][:ram],
          availabilityZone: Chef::Config[:knife][:availabilityzone],
          volumes: [volume_params],
          nics: [nic_params]
        }

        connection

        server = ProfitBricks::Server.create(
          Chef::Config[:knife][:datacenter_id],
          params.compact
        )

        dot = ui.color('.', :magenta)
        server.wait_for(300) { print dot; ready? }

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
