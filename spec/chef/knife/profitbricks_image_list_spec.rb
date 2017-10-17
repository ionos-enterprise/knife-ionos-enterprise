require 'spec_helper'
require 'profitbricks_image_list'

Chef::Knife::ProfitbricksImageList.load_deps

describe Chef::Knife::ProfitbricksImageList do
  let(:image_list) { Chef::Knife::ProfitbricksImageList.new }

  before :each do
    allow(image_list).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(image_list).to receive(:puts).with(/^ID\s+Name\s+Description\s+Location\s+Size\s+Public\s*$/)
      image_list.run
    end
  end
end
