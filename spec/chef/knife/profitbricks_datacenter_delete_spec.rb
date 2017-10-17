require 'spec_helper'
require 'profitbricks_datacenter_delete'

Chef::Knife::ProfitbricksDatacenterDelete.load_deps

describe Chef::Knife::ProfitbricksDatacenterDelete do
  subject { Chef::Knife::ProfitbricksDatacenterDelete.new }

  before :each do
    allow(subject).to receive(:puts)
    allow(subject.ui).to receive(:confirm)

    subject.config[:yes] = true

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
    subject.name_args = [@datacenter.id]
  end

  describe '#run' do
    it 'should delete a data center' do
      expect(subject).to receive(:puts).with('Name: Chef test')
      expect(subject).to receive(:puts).with('Description: Chef test datacenter')
      expect(subject).to receive(:puts).with('Location: us/las')
      subject.run
    end
  end
end
