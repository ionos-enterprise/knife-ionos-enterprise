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
             proc: proc { |datacenter_id| Chef::Config[:knife][:datacenter_id] = datacenter_id },
             required: true

      option :name,
             short: '-n NAME',
             long: '--name NAME',
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

      option :imagepassword,
             short: '-P PASSWORD',
             long: '--image-password PASSWORD',
             description: 'The password set on the image for the "root" or "Administrator" user'

      option :type,
             short: '-t TYPE',
             long: '--type TYPE',
             description: 'The disk type (HDD OR SSD)',
             required: true

      option :licencetype,
             short: '-l LICENCE',
             long: '--licence-type LICENCE',
             description: 'The licence type of the volume (LINUX, WINDOWS, UNKNOWN, OTHER)'

      option :sshkeys, 
             short: '-K SSHKEY[,SSHKEY,...]',
             long: '--ssh-keys SSHKEY1,SSHKEY2,...',
             description: 'A list of public SSH keys to include',
             proc: proc { |sshkeys| sshkeys.split(',') }

      def run
        $stdout.sync = true

        print "#{ui.color('Creating volume...', :magenta)}"

        params = {
          name: config[:name],
          size: config[:size],
          bus: config[:bus] || 'VIRTIO',
          image: config[:image],
          type: config[:type],
          licenceType: config[:licencetype],
        }

        if config[:sshkeys]
          params[:sshKeys] = config[:sshkeys]
        end

        if config[:imagepassword]
          params[:imagePassword] = config[:imagepassword]
        end

        connection
        volume = ProfitBricks::Volume.create(
          config[:datacenter_id],
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
        puts 'done'
      end
    end
  end
end
