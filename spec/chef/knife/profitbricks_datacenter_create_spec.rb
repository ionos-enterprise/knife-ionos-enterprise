require 'spec_helper'
require 'profitbricks_datacenter_create'

Chef::Knife::ProfitbricksDatacenterCreate.load_deps

describe Chef::Knife::ProfitbricksDatacenterCreate do
  subject { Chef::Knife::ProfitbricksDatacenterCreate.new }

  before :each do
    {
      name: 'Chef test',
      description: 'Chef test datacenter',
      location: 'us/las'
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end

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

    dcid = subject.instance_variable_get :@dcid
    datacenter = ProfitBricks::Datacenter.get(dcid)
    datacenter.delete
    datacenter.wait_for { ready? }
  end

  describe '#run' do
    it 'should create a data center' do
      expect(subject).to receive(:puts).with('Name: Chef test')
      expect(subject).to receive(:puts).with('Description: Chef test datacenter')
      expect(subject).to receive(:puts).with('Location: us/las')
      subject.run
    end
  end
end
