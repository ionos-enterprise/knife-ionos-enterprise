require 'spec_helper'
require 'profitbricks_ipblock_delete'

Chef::Knife::ProfitbricksIpblockDelete.load_deps

describe Chef::Knife::ProfitbricksIpblockDelete do
  subject { Chef::Knife::ProfitbricksIpblockDelete.new }

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

    @ip = ProfitBricks::IPBlock.reserve(name: 'Ruby SDK Test',
                                        location: 'us/las',
                                        size: 2)

    @ip.wait_for { ready? }
    subject.name_args = [@ip.id]
  end

  describe '#run' do
    it 'should delete a data center' do
      expect(subject).to receive(:puts).with('ID: ' + @ip.id)
      subject.run
    end
  end
end
