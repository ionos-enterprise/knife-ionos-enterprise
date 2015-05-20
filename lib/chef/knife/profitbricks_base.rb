require 'chef/knife'

class Chef
  class Knife
    module ProfitbricksBase
      def self.included(includer)
        includer.class_eval do
          deps do
            require 'profitbricks'
          end

          option :profitbricks_username,
            short: '-u USERNAME',
            long: '--username USERNAME',
            description: 'Your ProfitBricks username',
            proc: proc { |username| Chef::Config[:knife][:profitbricks_username] = username }

          option :profitbricks_password,
            short: '-p PASSWORD',
            long: '--password PASSWORD',
            description: 'Your ProfitBricks password',
            proc: proc { |password| Chef::Config[:knife][:profitbricks_password] = password }

          option :profitbricks_url,
            short: '-U URL',
            long: '--url URL',
            description: 'The ProfitBricks API URL',
            proc: proc { |url| Chef::Config[:knife][:profitbricks_url] = url }
        end
      end

      def connection
        ProfitBricks.configure do |config|
          config.username = Chef::Config[:knife][:profitbricks_username]
          config.password = Chef::Config[:knife][:profitbricks_password]
          config.url = Chef::Config[:knife][:profitbricks_url]
          config.debug = Chef::Config[:knife][:profitbricks_debug] || false
          config.global_classes = false
        end
      end

      def msg_pair(label, value, color = :cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end
    end
  end
end

# compact method will remove nil values from Hash
class Hash
  def compact
    delete_if { |_k, v| v.nil? }
  end
end
