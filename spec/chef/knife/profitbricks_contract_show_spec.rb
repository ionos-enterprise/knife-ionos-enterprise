require 'spec_helper'
require 'profitbricks_contract_show'

Chef::Knife::ProfitbricksContractShow.load_deps

describe Chef::Knife::ProfitbricksContractShow do
  let(:contract_list) { Chef::Knife::ProfitbricksContractShow.new }

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
