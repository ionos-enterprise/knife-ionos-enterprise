require 'spec_helper'
require 'profitbricks_volume_delete'

Chef::Knife::ProfitbricksVolumeDelete.load_deps

describe Chef::Knife::ProfitbricksVolumeDelete do
  subject { Chef::Knife::ProfitbricksVolumeDelete.new }

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

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    subject.name_args = [@volume.id]

    allow(subject).to receive(:puts)
    subject.config[:yes] = true
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
    it 'should delete a volume' do
      subject.run
    end
  end
end
