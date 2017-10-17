require 'spec_helper'
require 'profitbricks_location_list'

Chef::Knife::ProfitbricksLocationList.load_deps

describe Chef::Knife::ProfitbricksLocationList do
  before :each do
    subject { Chef::Knife::ProfitbricksLocationList.new }

    allow(subject).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(subject).to receive(:puts).with("ID      Name     \nde/fkb  karlsruhe\nde/fra  frankfurt\nus/las  lasvegas \nus/ewr  newark   \n")
      subject.run
    end

    it 'should output the data center locations' do
      expect(subject).to receive(:puts).with(/(?:us\/las)/)
      subject.run
    end
  end
end
