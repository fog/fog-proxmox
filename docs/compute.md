# Compute

This document shows you the compute service available with fog-proxmox.

Proxmox supports both virtual machines (QEMU/KVM) and containers (LXC) management.

You can see more details in [Proxmox VM management wiki page](https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines) and [Proxmox containers management wiki page](https://pve.proxmox.com/wiki/Linux_Container).

## Starting irb console

```ruby
irb
```

```ruby
require 'fog/proxmox'
```

## Create compute service

```ruby
compute = Fog::Compute::Proxmox.new(
        pve_username: PVE_USERNAME, # your user name
        pve_password: PVE_PASSWORD, # your password
        pve_url: PVE_URL # your server url
)
```

Optional [connection parameters](connection_parameters.md) are also available.

## Fog Abstractions

Fog provides both a **model** and **request** abstraction. The request abstraction provides the most efficient interface and the model abstraction wraps the request abstraction to provide a convenient `ActiveModel` like interface.

### Request Layer

The request abstraction maps directly to the [Proxmox VE API](https://pve.proxmox.com/wiki/Proxmox_VE_API). It provides an interface to the Proxmox Compute service.

To see a list of requests supported by the service:

```ruby
compute.requests
```

To learn more about Compute request methods refer to source files.

To learn more about Excon refer to [Excon GitHub repo](https://github.com/geemus/excon).

### Model Layer

Fog models behave in a manner similar to `ActiveModel`. Models will generally respond to `create`, `save`,  `persisted?`, `destroy`, `reload` and `attributes` methods. Additionally, fog will automatically create attribute accessors.

Here is a summary of common model methods:

<table>
	<tr>
		<th>Method</th>
		<th>Description</th>
	</tr>
	<tr>
		<td>create</td>
		<td>
			Accepts hash of attributes and creates object.<br>
			Note: creation is a non-blocking call and you will be required to wait for a valid state before using resulting object.
		</td>
	</tr>
	<tr>
		<td>save</td>
		<td>Saves object.<br>
		Note: not all objects support updating object.</td>
	</tr>
	<tr>
		<td>persisted?</td>
		<td>Returns true if the object has been persisted.</td>
	</tr>
	<tr>
		<td>destroy</td>
		<td>
			Destroys object.<br>
			Note: this is a non-blocking call and object deletion might not be instantaneous.
		</td>
	<tr>
		<td>reload</td>
		<td>Updates object with latest state from service.</td>
	<tr>
		<td>ready?</td>
		<td>Returns true if object is in a ready state and able to perform actions. This method will raise an exception if object is in an error state.</td>
	</tr>
	<tr>
		<td>attributes</td>
		<td>Returns a hash containing the list of model attributes and values.</td>
	</tr>
		<td>identity</td>
		<td>
			Returns the identity of the object.<br>
			Note: This might not always be equal to object.id.
		</td>
	</tr>
	<tr>
		<td>wait_for</td>
		<td>This method periodically reloads model and then yields to specified block until block returns true or a timeout occurs.</td>
	</tr>
</table>

The remainder of this document details the model abstraction.

#### Nodes management

Proxmox supports cluster management. Each hyperviser in the cluster is called a node.
Proxmox installs a default node in the cluster called `pve`.

List all nodes:

```ruby
service.nodes.all
```

This returns a collection of `Fog::Compute::Proxmox::Node` models:

Get a node:

```ruby
node = service.nodes.find_by_id 'pve'
```

#### Servers management

Proxmox supports servers management. Servers are also called virtual machines (VM).

VM are QEMU/KVM managed. They are attached to a node.

More details in [Proxmox VM management wiki page](https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines)

You need to specify a node before managing VM. Fog-proxmox enables it by managing VM from a node.

List all servers:

```ruby
node.servers.all
```

This returns a collection of `Fog::Identity::Proxmox::Server` models.

Before creating a server you can get the next available server id (integer >= 100) in the cluster:

```ruby
nextid = node.servers.next_id
```

You can also verify that an id is free or valid:

```ruby
node.servers.id_valid? nextid
```

Now that you have a valid id, you can create a server in this node:

```ruby
node.servers.create({
    vmid: nextid
})
```

Get this server:

```ruby
server = node.servers.get nextid
```

Add a cdrom volume:

```ruby
server.update({ ide2: 'none,media=cdrom' })
```

Add a network interface (nic):

```ruby
server.update({ net0: 'virtio,bridge=vmbr0' })
```

Before attaching a hdd volume, you can first fetch available storages in this node:

```ruby
storages = node.storages.all
storage = storages[0]
```

Four types of storage controllers emulated by Qemu are available:

* IDE: ide[n], n in 0..3
* SATA: sata[n], n in 0..5
* SCSI: scsi[n], n in 0..13
* VirtIO Block: virtio[n], n in 0..15

The volume id is the type controller appended with an integer (n).

More details on available configuration options can be find in [Proxmox VE API](https://pve.proxmox.com/wiki/Proxmox_VE_API).

Then attach a hdd volume from this storage:

```ruby
volume = { id: 'virtio0', storage: storage.storage, size: '1' } # virtualIO block with 1Gb
options = { backup: 0, replicate: 0 } # nor backup, neither replication
server.attach_volume(volume, options)
```

Delete server:

```ruby
server.destroy
```

More examples can be seen at [examples/compute.rb](examples/compute.rb) or [spec/compute_spec.rb](spec/compute_spec.rb).