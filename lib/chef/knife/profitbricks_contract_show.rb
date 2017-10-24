require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksContractShow < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks contract show'

      def run
        $stdout.sync = true
        connection
        contract = ProfitBricks::Contract.get

        puts "#{ui.color('Contract Type', :cyan)}: #{contract.type}"
        puts "#{ui.color('Contract Number', :cyan)}: #{contract.properties['contractNumber']}"
        puts "#{ui.color('Status', :cyan)}: #{contract.properties['status']}"
        puts "#{ui.color('Cores per server', :cyan)}: #{contract.properties['resourceLimits']['coresPerServer']}"
        puts "#{ui.color('Cores per contract', :cyan)}: #{contract.properties['resourceLimits']['coresPerContract']}"
        puts "#{ui.color('Cores provisioned', :cyan)}: #{contract.properties['resourceLimits']['coresProvisioned']}"
        puts "#{ui.color('RAM per server', :cyan)}: #{contract.properties['resourceLimits']['ramPerServer']}"
        puts "#{ui.color('RAM per contract', :cyan)}: #{contract.properties['resourceLimits']['ramPerContract']}"
        puts "#{ui.color('RAM provisioned', :cyan)}: #{contract.properties['resourceLimits']['ramProvisioned']}"
        puts "#{ui.color('HDD limit per volume', :cyan)}: #{contract.properties['resourceLimits']['hddLimitPerVolume']}"
        puts "#{ui.color('HDD limit per contract', :cyan)}: #{contract.properties['resourceLimits']['hddLimitPerContract']}"
        puts "#{ui.color('HDD volume provisioned', :cyan)}: #{contract.properties['resourceLimits']['hddVolumeProvisioned']}"
        puts "#{ui.color('SSD limit per volume', :cyan)}: #{contract.properties['resourceLimits']['ssdLimitPerVolume']}"
        puts "#{ui.color('SSD limit per contract', :cyan)}: #{contract.properties['resourceLimits']['ssdLimitPerContract']}"
        puts "#{ui.color('SSD volume provisioned', :cyan)}: #{contract.properties['resourceLimits']['ssdVolumeProvisioned']}"
        puts "#{ui.color('Reservable IPs', :cyan)}: #{contract.properties['resourceLimits']['reservableIps']}"
        puts "#{ui.color('Reservable IPs on contract', :cyan)}: #{contract.properties['resourceLimits']['reservedIpsOnContract']}"
        puts "#{ui.color('Reservable IPs in use', :cyan)}: #{contract.properties['resourceLimits']['reservedIpsInUse']}"

      end
    end
  end
end
