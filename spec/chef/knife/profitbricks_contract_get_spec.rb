require 'spec_helper'
require 'profitbricks_contract_get'

Chef::Knife::ProfitbricksContractGet.load_deps

describe Chef::Knife::ProfitbricksContractGet do
  let(:contract_list) { Chef::Knife::ProfitbricksContractGet.new }

  before :each do
    allow(contract_list).to receive(:puts)
  end

  describe '#run' do
    it 'should output the column headers' do
      expect(contract_list).to receive(:puts).with('Contract Type: contract')
      expect(contract_list).to receive(:puts).with('Status: BILLABLE')
      # expect(contract_list).to receive(:puts).with('Location: us/las')
      contract_list.run
    end
  end
end
