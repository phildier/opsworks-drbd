
# some shortcuts
primary_name = "filestore1"
instances = node[:opsworks][:layers][:filestore][:instances]
filestore1 = instances[:filestore1]
filestore2 = instances[:filestore2]
physical_volume = "/dev/xvdi"

puts instances
puts filestore1
puts filestore2

# unmount associated volume resource so drbd can use it
mount "/mnt/#{node[:opsworks][:instance][:hostname]}" do
	action :umount
	device physical_volume
end

# create nfs export dir
directory "/export"

# install iptables tool
include_recipe "iptables"

# configure drbd
node.override[:drbd][:disk][:location] = physical_volume
node.override[:drbd][:packages] = ["drbd-utils"]
node.override[:drbd][:master] = ( node[:opsworks][:instance][:hostname] == primary_name )

if node[:opsworks][:instance][:hostname] == "filestore1" then
	node.override[:drbd][:partner][:hostname] = filestore2[:hostname]
	node.override[:drbd][:partner][:ipaddress] = filestore2[:ip]
else
	node.override[:drbd][:partner][:hostname] = filestore1[:hostname]
	node.override[:drbd][:partner][:ipaddress] = filestore1[:ip]
end

node.override[:drbd][:primary][:fqdn] = instances[primary_name][:hostname]

node.override[:drbd][:server][:fqdn] = node[:opsworks][:instance][:hostname]
node.override[:drbd][:server][:ipaddress] = node[:opsworks][:instance][:ip]

puts node[:drbd]

if ::File.exists?("/etc/drbd.conf")
    # update the config
    include_recipe "extended_drbd::drbd_inplace_upgrade"
else
    # perform fresh install and init of drbd volume
    include_recipe "extended_drbd::drbd_fresh_install"
end

