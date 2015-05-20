require 'spec_helper'
require 'profitbricks_datacenter_list'

Chef::Knife::ProfitbricksDatacenterList.load_deps

describe Chef::Knife::ProfitbricksDatacenterList do
  before :each do
    subject { Chef::Knife::ProfitbricksDatacenterList.new }
    allow(subject).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(subject).to receive(:puts).with(/^ID\s+Name\s+Description\s+Location\s+Version\s*$/)
      subject.run
    end

    it 'should output the data center locations' do
      expect(subject).to receive(:puts).with(/(?:us\/las)/)
      subject.run
    end
  end
end
