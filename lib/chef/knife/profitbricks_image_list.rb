require 'chef/knife/profitbricks_base'

class Chef
  class Knife
    class ProfitbricksImageList < Knife
      include Knife::ProfitbricksBase

      banner 'knife profitbricks image list'

      def run
        $stdout.sync = true
        image_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Location', :bold),
          ui.color('Size', :bold),
          ui.color('Public', :bold)
        ]

        connection
        ProfitBricks::Image.list.each do |image|
          image_list << image.id
          image_list << image.properties['name']
          image_list << image.properties['description']
          image_list << image.properties['location']
          image_list << image.properties['size'].to_s
          image_list << image.properties['public'].to_s
        end

        puts ui.list(image_list, :columns_across, 6)
      end
    end
  end
end
