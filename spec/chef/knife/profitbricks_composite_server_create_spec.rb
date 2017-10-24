require 'spec_helper'
require 'profitbricks_composite_server_create'

Chef::Knife::ProfitbricksCompositeServerCreate.load_deps

describe Chef::Knife::ProfitbricksCompositeServerCreate do
  subject { Chef::Knife::ProfitbricksCompositeServerCreate.new }

  ProfitBricks.configure do |config|
    config.username = ENV['PROFITBRICKS_USERNAME']
    config.password = ENV['PROFITBRICKS_PASSWORD']
    config.url = ENV['PROFITBRICKS_API_URL']
    config.debug = false
    config.global_classes = false
  end

  before :each do
    @dcid = ''
    allow(subject).to receive(:puts)
  end

  after :each do
    datacenter = ProfitBricks::Datacenter.get(@dcid)
    datacenter.delete
  end

  describe '#run' do
    it 'should create a composite server' do

      datacenter = ProfitBricks::Datacenter.create(name: 'Chef test',
                                                   description: 'Chef test datacenter',
                                                   location: 'us/las')

      datacenter.wait_for { ready? }

      @dcid = datacenter.id

      {
        profitbricks_username: ENV['PROFITBRICKS_USERNAME'],
        profitbricks_password: ENV['PROFITBRICKS_PASSWORD'],
        profitbricks_url: ENV['PROFITBRICKS_API_URL'],
        name: 'Chef test',
        cores: '2',
        ram: '2048',
        size: 4,
        dhcp: true,
        lan: 1,
        datacenter_id: @dcid,
        imagealias: 'ubuntu:latest',
        type: 'HDD',
        imagepassword: 'K3tTj8G14a3EgKyNeeiY'
      }.each do |key, value|
        Chef::Config[:knife][key] = value
      end

      expect(subject).to receive(:puts).with('Name: Chef test')
      expect(subject).to receive(:puts).with('Cores: 2')
      expect(subject).to receive(:puts).with('CPU Family: ')
      expect(subject).to receive(:puts).with('Ram: 2048')
      expect(subject).to receive(:puts).with('Availability Zone: ')
      subject.run
    end
  end
end
