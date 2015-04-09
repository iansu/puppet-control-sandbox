# Puppet Control Sandbox

This is an environment for developing a Puppet control repo and Puppet modules.
It uses Vagrant to create a VM that acts as the Puppet Master and Puppet Agent
for testing and development.


## Usage

1. Clone this repo
2. Clone the Puppet control repo into `puppet-control/<environment>/` (development by default)
3. Clone any Puppet modules you want to develop into `puppet-modules/`
4. Make sure the `puppet_environment` fact in the Vagrantfile matches the name of your environment
5. Run `vagrant up` to start the VM
6. Run `vagrant ssh` to access the VM
7. Optional: assign a role to your node by editing `/etc/facter/facts.d/role.txt`
8. Run `sudo puppet agent --test` to apply the Puppet config
9. Make any changes to the Puppet control repo and/or Puppet modules
10. Run `sudo puppet agent --test` to apply the updated config
11. Repeat steps 9 and 10 until you are satisfied with your changes
12. Commit any changes you made to the Puppet control repo and/or Puppet modules
13. Run `vagrant halt` to shut down the Puppet Master


## VirtualBox Snapshots

There is a Vagrant plugin that allows you to snapshot a VirtualBox VM. This is
very useful when developing Puppet code. You can snapshot your VM immediately
after starting it and then easily revert any changes made after that.

1. Install the plugin by running `vagrant plugin install vagrant-vbox-snapshot`
2. After running `vagrant up` snapshot the VM by running `vagrant snapshot take <name>`
3. To revert to the previous snapshot run `vagrant snapshot back`


## Notes

* In order to use the modules in the puppet-modules directory the modulepath in
environment.conf in your Puppet control repo must include $basemodulepath
before any environment specific module directories. For example:
`modulepath = $basemodulepath:modules:site`
* This development environment currently uses a single Vagrant VM as both the
Puppet Master and Puppet Agent. In the future it might be desirable to support
multiple Vagrant VMs, one that acts as the Puppet Master and others that act as
Puppet Agent nodes.
