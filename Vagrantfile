# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.box = "ubuntu1404-opsworks"

#	config.vm.network :forwarded_port, guest: 80, host: 8080


	# install chef-dk and other bootstrap things
#	config.vm.provision :shell, path: "scripts/vagrant_bootstrap.sh"
	

	config.vm.define "drbd1" do |drbd1|

		drbd1.vm.hostname = "drbd1"
		drbd1.vm.network :private_network, ip: "10.59.0.10"
		file_to_disk = "drbd1.vdi"
		drbd1.vm.provider "virtualbox" do |vb|
#			vb.gui = true
			unless File.exists?(file_to_disk)
				vb.customize ['createhd', '--filename', file_to_disk, '--size', 512]
			end
			vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
		end

		drbd1.vm.provision "chef_solo" do |chef|
			chef.cookbooks_path = [".","berks-cookbooks"]
			chef.roles_path = ["."]
			chef.add_role "drbd1"
		end
	end

	config.vm.define "drbd2" do |drbd2|

		drbd2.vm.hostname = "drbd2"
		drbd2.vm.network :private_network, ip: "10.59.0.11"
		file_to_disk = "drbd2.vdi"
		drbd2.vm.provider "virtualbox" do |vb|
#			vb.gui = true
			unless File.exists?(file_to_disk)
				vb.customize ['createhd', '--filename', file_to_disk, '--size', 512]
			end
			vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
		end

		drbd2.vm.provision "chef_solo" do |chef|
			chef.cookbooks_path = [".","berks-cookbooks"]
			chef.roles_path = ["."]
			chef.add_role "drbd2"
		end
	end

end
