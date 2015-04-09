# -*- mode: ruby -*-
# vi: set ft=ruby :

$provision_script = <<EOF
mkdir -p /etc/puppet/modules

function install_module {
  folder=`echo $1 | sed s/.*-//`
  if [ ! -d /etc/puppet/modules/$folder ]; then
    puppet module install $1
  fi
}

install_module zack-r10k
install_module hunner-hiera
EOF

Vagrant.configure(2) do |config|
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  config.vm.hostname = "puppet-master-dev"

  config.vm.synced_folder "puppet-control", "/etc/puppet/environments"
  config.vm.synced_folder "puppet-modules", "/opt/puppet/modules"

  # Increase VM memory if required
  #config.vm.provider "virtualbox" do |vb|
  #  vb.customize ["modifyvm", :id, "--memory", "2048"]
  #end

  config.vm.provision "shell", :inline => $provision_script

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "provision/puppet/manifests"
    puppet.module_path = "provision/puppet/modules"
    puppet.manifest_file = "provision.pp"
    puppet.facter = {
      # Make sure this matches the name of your environment in the puppet-control directory
      "puppet_environment" => "development"
    }
  end
end
