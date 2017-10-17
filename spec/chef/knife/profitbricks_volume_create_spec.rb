require 'spec_helper'
require 'profitbricks_volume_create'

Chef::Knife::ProfitbricksVolumeCreate.load_deps

describe Chef::Knife::ProfitbricksVolumeCreate do
  subject { Chef::Knife::ProfitbricksVolumeCreate.new }

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

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    Chef::Config[:knife][:image] = image.id
    Chef::Config[:knife][:size] = 4
    Chef::Config[:knife][:name] = 'Chef Test'
    Chef::Config[:knife][:type] = image_type
    Chef::Config[:knife][:imagepassword] = 'aheoizj4689'

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
    it 'should create a volume' do
      expect(subject).to receive(:puts).with('Size: 4')
      expect(subject).to receive(:puts).with('Bus: ')
      expect(subject).to receive(:puts).with('Type: HDD')
      expect(subject).to receive(:puts).with('Licence Type: LINUX')
      expect(subject).to receive(:puts).with('Zone: AUTO')
      subject.run
    end
  end
end
