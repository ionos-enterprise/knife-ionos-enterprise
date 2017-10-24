require 'spec_helper'
require 'profitbricks_contract_list'

Chef::Knife::ProfitbricksContractList.load_deps

describe Chef::Knife::ProfitbricksContractList do
  let(:contract_list) { Chef::Knife::ProfitbricksContractList.new }

  before :each do
    allow(contract_list).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(contract_list).to receive(:puts).with('Contract Type: contract')
      expect(contract_list).to receive(:puts).with('Status: BILLABLE')
      contract_list.run
    end
  end
end
