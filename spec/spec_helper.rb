$:.unshift File.expand_path('../../lib/chef/knife', __FILE__)
require 'rspec'
require 'chef'

RSpec.configure do |config|
  config.before(:each) do
    Chef::Config.reset
    {
      profitbricks_username: ENV['PROFITBRICKS_USERNAME'],
      profitbricks_password: ENV['PROFITBRICKS_PASSWORD'],
      profitbricks_url: ENV['PROFITBRICKS_API_URL']
    }.each do |key, value|
      Chef::Config[:knife][key] = value
    end
  end
end

class Chef
  class Knife
  end
end

def get_image(image_name, image_type, image_location)
  images = ProfitBricks::Image.list
  min_image = nil
  images.each do |image|

    has_substring = image.properties['name'].downcase.include? image_name
    if  image.properties['public'] == true && image.properties['imageType'] == image_type && image.properties['location'] == image_location && has_substring
      min_image = image
    end
  end
    min_image
end
