require 'spec_helper'
require 'profitbricks_datacenter_list'

Chef::Knife::ProfitbricksDatacenterList.load_deps

describe Chef::Knife::ProfitbricksDatacenterList do
  let(:datacenter_list) { Chef::Knife::ProfitbricksDatacenterList.new }

  before :each do
    allow(datacenter_list).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(datacenter_list).to receive(:puts).with(/^ID\s+Name\s+Description\s+Location\s+Version\s*$/)
      datacenter_list.run
    end

    it 'should output the data center locations' do
      expect(datacenter_list).to receive(:puts).with(/^ID\s+Name\s+Description\s+Location\s+Version\s*$/)
      datacenter_list.run
    end
  end
end
