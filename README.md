# Knife ProfitBricks

## Description

ProfitBricks Chef Knife plugin

## Requirements

* Chef 12.3.0 or higher
* Ruby 2.0.x or higher

## Installation

Add this line to your application's Gemfile:

    gem 'knife-profitbricks'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install knife-profitbricks

## Configuration

The ProfitBricks Chef Knife plugin requires valid ProfitBricks account credentials. These credentials can be added to the `knife.rb` configuration file.

    knife[:profitbricks_username] = 'username'
    knife[:profitbricks_password] = 'password'

If a virtual data center has already been created under the ProfitBricks account, then the data center ID can be added to the `knife.rb` which reduces the need to include the --datacenter-id parameter for each action within the data center.
 
    knife[:datacenter_id] = 'f3f3b6fe-017d-43a3-b42a-a759144b2e99'

Optional parameters include the following:

    knife[:profitbricks_url] = 'https://api.profitbricks.com'
    knife[:profitbricks_debug] = true
 
## Sub Commands

### knife profitbricks datacenter create

Creates a new data center where servers, volumes, and other resources will reside.

### knife profitbricks datacenter delete

**USE WITH EXTREME CAUTION**

Deletes an existing data center and all resources within that data center.

### knife profitbricks datacenter list

List all available data centers under the ProfitBricks account.

### knife profitbricks firewall create

Creates a new firewall rule on an existing NIC.

### knife profitbricks firewall delete

Deletes a firewall rule from an existing NIC.

### knife profitbricks firewall list

Lists all available firewall rules assigned to a NIC.

### knife profitbricks image list

Lists all available images.

### knife profitbricks ipblock create

Reserves a new IP block.

### knife profitbricks ipblock delete

Releases a currently assigned IP block.

### knife profitbricks ipblock list

Lists all available IP blocks.

### knife profitbricks lan create

Creates a new LAN under a data center.

### knife profitbricks lan delete

Deletes an existing LAN.

### knife profitbricks lan list

Lists all available LANs under a data center.

### knife profitbricks location list

List all available regions where a data center may reside.

### knife profitbricks nic create

Creates a NIC on the specified server.

### knife profitbricks nic delete

Deletes an existing NIC from a server.

### knife profitbricks nic list

List all available NICs connected to a server.

### knife profitbricks composite server create

Creates a new composite server with attached volume and NIC in a specified data center.

### knife profitbricks server create

Creates a new server within a specified data center.

### knife profitbricks server delete

Deletes an existing server.

### knife profitbricks server list

List all available servers under a specified data center.

### knife profitbricks server reboot

Performs a hard reset on a server.

### knife profitbricks server start

Starts a server.

### knife profitbricks server stop

Stops a server.

### knife profitbricks volume attach

Attaches an existing volume to a server.

### knife profitbricks volume create

Creates a new volume.

### knife profitbricks volume delete

Deletes an existing volume.

### knife profitbricks volume detach

Detaches a volume from a server.

### knife profitbricks volume list

Lists all available volumes under a data center. Passing the `--server-id` parameter will also list all volumes attached to the specified server.

## Examples

To review a list of existing data centers:

    knife profitbricks datacenter list

The first step is to usually identify a location where the data center should reside as well as an image to use. It is **important** to note that the image must exist in the same location as the data center. Make a note of the image UUID.

    knife profitbricks image list
    knife profitbricks location list

Now the data center can be created.

    knife profitbricks datacenter create --name "Production" --description "Production webserver environment" --location "us/las"

Once the data center is provisioned, both a server and volume can be created. The volume will use an existing image as identified above.

    knife profitbricks server create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "Frontend Webserver" --cores 1 --ram 1024 --availability-zone ZONE_1 --cpu-family INTEL_XEON
    knife profitbricks volume create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "OS Volume" --size 5 --type HDD --image c4263e0f-e75e-11e4-91fd-8fa3eaae9f6b --ssh-keys "ssh-rsa AAAAB3NzaC1..."

The volume can then be attached to the server.

    knife profitbricks volume attach --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804 9b45f734-01ec-46ca-b163-d06c5a9d707f

Now a NIC can be added the new server. The LAN will automatically be created if a non-existent LAN ID is passed with the `--lan` parameter.

    knife profitbricks nic create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804 --name "Primary NIC" --lan 1

Here is an example of adding a firewall rule to the newly created NIC.

    knife profitbricks firewall create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804 --nic-id e4270ecc-e9c5-4de0-940a-8a0a99d962fd --name "SSH" --protocol TCP --port-range-start 22 --port-range-end 22 --source-ip 203.0.113.10

A composite server can also be created with attached volume and NIC in a single command.

    knife profitbricks composite server create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "Backend Database" --cores 1 --ram 8192 --size 5 --type SSD --lan 1 --image 2ead2908-df61-11e5-80a4-52540005ab80 --ssh-keys "ssh-rsa AAAAB3NzaC1..."

The new data center and **all resources within that data center** can be deleted.

    knife profitbricks datacenter delete ade28808-9253-4d4e-9f5d-f1f7f1038fb1

## Documentation and Support

* [ProfitBricks REST API](https://devops.profitbricks.com/api/rest/) documentation.
* Ask a question or discuss at [ProfitBricks DevOps Central](https://devops.profitbricks.com/community).

## Testing

    $ rspec spec

## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-profitbricks/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
