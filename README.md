# ProfitBricks Chef Knife Plugin

## Table of Contents

* [Concepts](#concepts)
* [Requirements](#requirements)
* [Getting Started](#getting-started)
* [Installation](#installation)
* [Configuration](#configuration)
* [How To](#how-to)
    * [List Data Centers](#list-data-centers)
    * [Create Data Center](#create-data-center)
    * [Create Server](#create-server)
    * [List Servers](#list-servers)
    * [List Images](#list-images)
    * [Create Volume](#create-volume)
    * [List Volumes](#list-volumes)
    * [Attach and Detach Volume](#attach-and-detach-volume)
    * [Reserve IP Block](#reserve-ip-block)
    * [Create Public LAN](#create-public-lan)
    * [Create NIC](#create-nic)
    * [Create Composite Server](#create-composite-server)
    * [Delete Data Center](#delete-data-center)
* [Reference](#reference)
    * [Location](#location)
    * [Data Center](#data-center)
    * [Server](#server)
    * [Volume](#volume)
    * [Image](#image)
    * [LAN](#lan)
    * [NIC](#nic)
    * [IP Block](#ip-block)
    * [Firewall](#firewall)
    * [Failover IP](#failover-ips)
* [Support](#support)
* [Testing](#testing)
* [Contributing](#contributing)

## Concepts

Chef is a popular configuration management tool that allows simplified configuration and maintenance of both servers and cloud provider environments through the use of common templates called recipes. The Chef `knife` command line tool allows management of various nodes within those environments. The `knife-profitbricks` plugin utilizes the ProfitBricks REST API to provision and manage various cloud resources on the ProfitBricks platform.

## Requirements

* Chef 12.3.0 or higher
* Ruby 2.0.x or higher

## Getting Started

Before you begin you will need to have [signed-up](https://www.profitbricks.com/signup/) for a ProfitBricks account. The credentials you establish during sign-up will be used to authenticate against the [ProfitBricks Cloud API](https://devops.profitbricks.com/api/).

## Installation

The `knife-profitbricks` plugin can be installed as a gem:

    $ gem install knife-profitbricks

Or the plugin can be installed by adding the following line to your application's Gemfile:

    gem 'knife-profitbricks'

And then execute:

    $ bundle

## Configuration

The ProfitBricks account credentials can be added to the `knife.rb` configuration file.

    knife[:profitbricks_username] = 'username'
    knife[:profitbricks_password] = 'password'

If a virtual data center has already been created under the ProfitBricks account, then the data center UUID can be added to the `knife.rb` which reduces the need to include the `--datacenter-id [datacenter_id]` parameter for each action within the data center.

    knife[:datacenter_id] = 'f3f3b6fe-017d-43a3-b42a-a759144b2e99'

Optional parameters include the following:

    knife[:profitbricks_url] = 'https://api.profitbricks.com'
    knife[:profitbricks_debug] = true

The configuration parameters can also be passed using shell environment variables. First, the following should be added to the `knife.rb` configuration file:

    knife[:profitbricks_username] = ENV['PROFITBRICKS_USERNAME']
    knife[:profitbricks_password] = ENV['PROFITBRICKS_PASSWORD']

Now the parameters can be set as environment variables:

    $ export PROFITBRICKS_USERNAME='username'
    $ export PROFITBRICKS_PASSWORD='password'

# How To

## List Data Centers

ProfitBricks introduces the concept of virtual data centers. These are logically separated from one another and allow you to have a self-contained environment for all servers, volumes, networking, and other resources. The goal is to give you the same experience as you would have if you were running your own physical data center.

A list of available data centers can be obtained with the following command.

    knife profitbricks datacenter list

## Create Data Center

Unless you are planning to manage an existing ProfitBricks environment, the first step will typically involve choosing the location for a new virtual data center. A list of locations can be obtained with location command.

    knife profitbricks location list

Make a note of the desired location ID and now the data center can be created.

    knife profitbricks datacenter create --name "Production" --description "Production webserver environment" --location "us/las"

## Create Server

One of the unique features of the ProfitBricks platform when compared with the other providers is that they allow you to define your own settings for cores, memory, and disk size without being tied to a particular size or flavor.

Note: *The memory parameter value must be a multiple of 256, e.g. 256, 512, 768, 1024, and so forth.*

The following example shows you how to create a new server in the data center created above:

    knife profitbricks server create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "Frontend Webserver" --cores 1 --ram 1024 --availability-zone ZONE_1 --cpu-family INTEL_XEON

## List Servers

The new server should appear when listing all servers under the specified data center.

    knife profitbricks server list --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1

## List Images

A list of disk and ISO images are available from ProfitBricks for immediate use. These can be easily reviewed and selected with the following command.

    knife profitbricks image list

Make sure the image you use is in the same location as the virtual data center.

## Create Volume

ProfitBricks allows for the creation of multiple storage volumes that can be attached and detached as needed. It is useful to attach an image when creating a storage volume. The storage size is in gigabytes (GB).

    knife profitbricks volume create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "OS Volume" --size 20 --type HDD --image c4263e0f-e75e-11e4-91fd-8fa3eaae9f6b --ssh-keys "ssh-rsa AAAAB3NzaC1..."

## List Volumes

The following example will list all available volumes under a data center.

    knife profitbricks volume list --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1

You can also list all volumes attached to a specific server.

    knife profitbricks volume list --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804

## Attach and Detach Volume

ProfitBricks allows for the creation of multiple storage volumes. You can detach and reattach these on the fly. This allows for various scenarios such as re-attaching a failed OS disk to another server for possible recovery or moving a volume to another location and bringing it online.

The following illustrates how you would attach a volume with a UUID of 9b45f734-01ec-46ca-b163-d06c5a9d707f to a server:

    knife profitbricks volume attach --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804 9b45f734-01ec-46ca-b163-d06c5a9d707f

If you need to detach the same volume:

    knife profitbricks volume detach --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804 9b45f734-01ec-46ca-b163-d06c5a9d707f

## Reserve IP Block

The IP block size (number of IP addresses) and location are required to reserve an IP block:

    knife profitbricks ipblock create --size 5 --location "us/las"

## Create Public LAN

A pubic LAN must be created within a data center.

    knife profitbricks lan create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "Public Network" --public

## Create NIC

The ProfitBricks platform supports adding multiple NICs to a server. These NICs can be used to create different, segmented networks on the platform.

The example below shows you how to add a second NIC to an existing server and LAN:

    knife profitbricks nic create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --server-id 2e438d3b-02f0-47d0-8594-4ace38ed2804 --name "Public NIC" --lan 1

## Create Composite Server

This creates a new composite server with an attached volume and NIC in a specified virtual data center.

    knife profitbricks composite server create --datacenter-id ade28808-9253-4d4e-9f5d-f1f7f1038fb1 --name "Backend Database" --cores 1 --ram 8192 --size 5 --type SSD --lan 1 --image 2ead2908-df61-11e5-80a4-52540005ab80 --ssh-keys "ssh-rsa AAAAB3NzaC1..."

## Delete Data Center

You will want to exercise a bit of caution here. Removing a data center will destroy all objects contained within that data center -- servers, volumes, snapshots, and so on. The objects -- once removed -- will be unrecoverable.

    knife profitbricks datacenter delete ade28808-9253-4d4e-9f5d-f1f7f1038fb1

# Reference

## Location

### List Locations

List available physical locations where resources can reside.

    knife profitbricks location list

## Data Center

### List Data Centers

List all available data centers under the ProfitBricks account.

    knife profitbricks datacenter list

### Create Data Center

Creates a new data center where servers, volumes, and other resources will reside.

    knife profitbricks datacenter create --name [string] --description [string] --location [location_id]

### Delete Data Center

* **USE WITH EXTREME CAUTION**

Deletes an existing data center and all resources within that data center.

    knife profitbricks datacenter delete [datacenter_id]

## Server

### List Servers

List all available servers under a specified data center.

    knife profitbricks server list --datacenter-id [datacenter_id]

### Create Server

Creates a new server within a specified data center.

    knife profitbricks server create --datacenter-id [datacenter_id] --name [string] --cores [int] --ram [int] ...

### Delete Server

Deletes an existing server.

    knife profitbricks server delete --datacenter-id [datacenter_id] [server_id]

### Reboot Server

Performs a hard reset on a server.

    knife profitbricks server reboot --datacenter-id [datacenter_id] [server_id]

### Start Server

Starts a server.

    knife profitbricks server start --datacenter-id [datacenter_id] [server_id]

### Stop Server

Stops a server.

    knife profitbricks server stop --datacenter-id [datacenter_id] [server_id]

## Volume

### List Volumes

Lists all available volumes under a data center. Passing the `--server-id` parameter will also list all volumes attached to the specified server.

    knife profitbricks volume list --datacenter-id [datacenter_id]

    knife profitbricks volume list --datacenter-id [datacenter_id] --server-id [server_id]

### Create Volume

Creates a new volume.

    knife profitbricks volume create --datacenter-id [datacenter_id] --name [string] --size [int] --image [image_id] ...

### Delete Volume

Deletes an existing volume.

    knife profitbricks volume delete --datacenter-id [datacenter_id] [volume_id]

### Attach Volume

Attaches an existing volume to a server.

    knife profitbricks volume attach --datacenter-id [datacenter_id] --server-id [server_id] [volume_id]

### Detach Volume

Detaches a volume from a server.

    knife profitbricks volume detach --datacenter-id [datacenter_id] --server-id [server_id] [volume_id]

## Image

### List Images

Lists all available images.

    knife profitbricks image list

## LAN

### List LANs

Lists all available LANs under a data center.

    knife profitbricks lan list

### Create LAN

Creates a new LAN under a data center.

    knife profitbricks lan create --datacenter-id [datacenter_id] --name [string] [--public]

### Delete LAN

Deletes an existing LAN.

    knife profitbricks lan delete --datacenter-id [datacenter_id]

## NIC

### List NICs

List all available NICs connected to a server.

    knife profitbricks nic list

### Create NIC

Creates a NIC on the specified server.

    knife profitbricks nic create --datacenter-id [datacenter_id] --server-id [server_id] --name [string] --lan [int] -ips IP[,IP,...] [--dhcp]

### Delete NIC

Deletes an existing NIC from a server.

    knife profitbricks nic delete --datacenter-id [datacenter_id] [nic_id]

## IP Block

### List IP Blocks

Lists all available IP blocks.

    knife profitbricks ipblock list

### Reserve IP Block

Reserve a new IP block.

    knife profitbricks ipblock create --size [int] --location [string]

### Release IP Block

Releases a currently assigned IP block.

    knife profitbricks ipblock delete [ipblock_id]

## Firewall

### List Firewall Rules

Lists all available firewall rules assigned to a NIC.

    knife profitbricks firewall list

### Create Firewall Rule

Creates a new firewall rule on an existing NIC.

    knife profitbricks firewall create --datacenter-id [datacenter_id] --server-id [server_id] --nic-id [nic_id] --name [string] --protocol [TCP, UDP] --port-range-start [int] --port-range-end [int] --source-ip [IP]

### Delete Firewall Rule

Deletes a firewall rule from an existing NIC.

    knife profitbricks firewall delete --datacenter-id [datacenter_id] --server-id [server_id] --nic-id [nic_id] [firewall_id]

## IP Failover

### Add IP failover to LAN

Adds IPs to LAN

    knife profitbricks failover add --datacenter_id [datacenter_id] --lan_id [lan_id] --ip [ip1] --nic_id [nic_id]

### Remove IP Failover from LAN

Remove IP Failover from LAN

    knife profitbricks failover remove --datacenter_id [datacenter_id] --lan_id [lan_id] --ip [ip1] --nic_id [nic_id]

## Contract Resources

Lists information about available contract resources

    knife profitbricks contract get

## Support

Please report any issues through the [project repository on GitHub](https://github.com/profitbricks/knife-profitbricks).

Questions and discussions can be directed to [ProfitBricks DevOps Central](https://devops.profitbricks.com/) site.

## Testing

    $ rspec spec

## Contributing

1. Fork it ( https://github.com/[my-github-username]/knife-profitbricks/fork ).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request.
