require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksVolumeCreate < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks volume create (options)'

      option :datacenter_id,
             short: '-D DATACENTER_ID',
             long: '--datacenter-id DATACENTER_ID',
             description: 'Name of the data center',
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id }

      option :name,
             short: '-n NAME',
             long: '--name NAME',
             description: 'Name of the volume'

      option :size,
             short: '-S SIZE',
             long: '--size SIZE',
             description: 'The size of the volume in GB'

      option :bus,
             short: '-b BUS',
             long: '--bus BUS',
             description: 'The bus type of the volume (VIRTIO or IDE)'

      option :image,
             short: '-N ID',
             long: '--image ID',
             description: 'The image or snapshot ID'

       option :imagealias,
              long: '--image-alias IMAGE_ALIAS',
              description: '(required) The image alias'

      option :imagepassword,
             short: '-P PASSWORD',
             long: '--image-password PASSWORD',
             description: 'The password set on the image for the "root" or "Administrator" user'

      option :type,
             short: '-t TYPE',
             long: '--type TYPE',
             description: 'The disk type (HDD OR SSD)'

      option :licencetype,
             short: '-l LICENCE',
             long: '--licence-type LICENCE',
             description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :sshkeys,
             short: '-K SSHKEY[,SSHKEY,...]',
             long: '--ssh-keys SSHKEY1,SSHKEY2,...',
             description: 'A list of public SSH keys to include',
             proc: proc { |sshkeys| sshkeys.split(',') }

      option :volume_availability_zone,
             short: '-Z AVAILABILITY_ZONE',
             long: '--availability-zone AVAILABILITY_ZONE',
             description: 'The volume availability zone of the server',
             required: false

      def run
        $stdout.sync = true
        validate_required_params(%i(datacenter_id name type size), Chef::Config[:knife])

        if !Chef::Config[:knife][:image] && !Chef::Config[:knife][:imagealias]
          ui.error("Either '--image' or '--image-alias' parameter must be provided")
          exit(1)
        end

        if !Chef::Config[:knife][:sshkeys] && !Chef::Config[:knife][:imagepassword]
          ui.error("Either '--image-password' or '--ssh-keys' parameter must be provided")
          exit(1)
        end

        print "#{ui.color('Creating volume...', :magenta)}"

        params = {
          name: Chef::Config[:knife][:name],
          size: Chef::Config[:knife][:size],
          bus: Chef::Config[:knife][:bus] || 'VIRTIO',
          type: Chef::Config[:knife][:type],
          licenceType: Chef::Config[:knife][:licencetype],
        }

        if Chef::Config[:knife][:image]
          params['image'] = Chef::Config[:knife][:image]
        end

        if Chef::Config[:knife][:imagealias]
          params['imageAlias'] = Chef::Config[:knife][:imagealias]
        end

        if Chef::Config[:knife][:sshkeys]
          params[:sshKeys] = Chef::Config[:knife][:sshkeys]
        end

        if Chef::Config[:knife][:imagepassword]
          params[:imagePassword] = Chef::Config[:knife][:imagepassword]
        end

        if Chef::Config[:knife][:volume_availability_zone]
          params[:availabilityZone] = Chef::Config[:knife][:volume_availability_zone]
        end

        connection
        volume = ProfitBricks::Volume.create(
          Chef::Config[:knife][:datacenter_id],
          params.compact
        )

        dot = ui.color('.', :magenta)
        volume.wait_for(300) { print dot; ready? }
        volume.reload

        puts "\n"
        puts "#{ui.color('ID', :cyan)}: #{volume.id}"
        puts "#{ui.color('Name', :cyan)}: #{volume.properties['name']}"
        puts "#{ui.color('Size', :cyan)}: #{volume.properties['size']}"
        puts "#{ui.color('Bus', :cyan)}: #{volume.properties['bus']}"
        puts "#{ui.color('Image', :cyan)}: #{volume.properties['image']}"
        puts "#{ui.color('Type', :cyan)}: #{volume.properties['type']}"
        puts "#{ui.color('Licence Type', :cyan)}: #{volume.properties['licenceType']}"
        puts "#{ui.color('Zone', :cyan)}: #{volume.properties['availabilityZone']}"
        puts 'done'
      end
    end
  end
end
