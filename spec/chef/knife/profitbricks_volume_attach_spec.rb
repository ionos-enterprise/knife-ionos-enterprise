require 'spec_helper'
require 'profitbricks_volume_attach'

Chef::Knife::ProfitbricksVolumeAttach.load_deps

describe Chef::Knife::ProfitbricksVolumeAttach do
  subject { Chef::Knife::ProfitbricksVolumeAttach.new }

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

    @server = ProfitBricks::Server.create(@datacenter.id, name: 'Chef Test',
                                                          ram: 1024,
                                                          cores: 1,
                                                          availabilityZone: 'ZONE_1',
                                                          cpuFamily: 'INTEL_XEON')
    @server.wait_for { ready? }

    @volume = ProfitBricks::Volume.create(@datacenter.id, size: 2,
                                                          type: 'HDD',
                                                          licenceType: 'UNKNOWN',
                                                          availabilityZone: 'ZONE_3',
                                                          bus: 'VIRTIO')

    @volume.wait_for(300) { ready? }

    Chef::Config[:knife][:datacenter_id] = @datacenter.id
    Chef::Config[:knife][:server_id] = @server.id
    subject.name_args = [@volume.id]

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
    it 'should attach a volume' do
      subject.run
    end
  end
end
