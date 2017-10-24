require 'spec_helper'
require 'profitbricks_volume_list'

Chef::Knife::ProfitbricksVolumeList.load_deps

describe Chef::Knife::ProfitbricksVolumeList do
  subject { Chef::Knife::ProfitbricksVolumeList.new }

  before :each do
    {
      name: 'Chef Test',
      public: 'true'
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

    ProfitBricks.configure do |config|
      config.username = Chef::Config[:knife][:profitbricks_username]
      config.password = Chef::Config[:knife][:profitbricks_password]
      config.url = Chef::Config[:knife][:profitbricks_url]
      config.debug = Chef::Config[:knife][:profitbricks_debug] || false
      config.global_classes = false
    end

    @datacenter = ProfitBricks::Datacenter.create(name: 'Chef test',
                                                  description: 'Chef test datacenter',
                                                  location: 'us/las')
    @datacenter.wait_for { ready? }

    location = 'us/las'
    image_name = 'ubuntu'
    image_type = 'HDD'

    image = get_image(image_name, image_type, location)

    @volume = ProfitBricks::Volume.create(@datacenter.id, size: 2,
                                                          type: 'HDD',
                                                          availabilityZone: 'ZONE_3',
                                                          image: image.id,
                                                          imagePassword: 'aoiaio00q235',
                                                          bus: 'VIRTIO')

    @volume.wait_for(300) { ready? }

    @server = ProfitBricks::Server.create(@datacenter.id, name: 'Chef Test',
                                                          ram: 1024,
                                                          cores: 1,
                                                          availabilityZone: 'ZONE_1',
                                                          cpuFamily: 'INTEL_XEON')
    @server.wait_for { ready? }

    @volume.attach(@server.id)
    @volume.wait_for(300) { ready? }

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    Chef::Config[:knife][:server_id] = @server.id

    allow(subject).to receive(:puts)
  end

  after :each do
    ProfitBricks.configure do |config|
      config.username = Chef::Config[:knife][:profitbricks_username]
      config.password = Chef::Config[:knife][:profitbricks_password]
      config.url = Chef::Config[:knife][:profitbricks_url]
      config.debug = Chef::Config[:knife][:profitbricks_debug] || false
      config.global_classes = false
    end

    @datacenter.delete
    @datacenter.wait_for { ready? }
  end

  describe '#run' do
    it 'should list volumes' do
      expect(subject).to receive(:puts).with(/^ID\s+Name\s+Size\s+Bus\s+Image\s+Type\s+Zone\s+Device Number\s*$/)
      subject.run
    end
  end
end
