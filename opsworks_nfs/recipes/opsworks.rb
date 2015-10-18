
# unmount associated volume resource so drbd can use it
mount "/mnt/#{node[:opsworks][:instance][:hostname]}" do
	action :umount
end

# create nfs export dir
directory "/export"

# install iptables tool
include_recipe "iptables"

primary_name = "filestore1"

# configure drbd
node.override[:drbd][:disk][:location] = "/dev/xvdi"
node.override[:drbd][:packages] = ["drbd-utils"]
node.override[:drbd][:master] = ( node[:opsworks][:instance][:hostname] == primary_name )

if node[:opsworks][:instance][:hostname] == "filestore1" then
	node.override[:drbd][:partner][:hostname] = node[:opsworks][:instances][:filestore2][:public_dns_name]
	node.override[:drbd][:partner][:ipaddress] = node[:opsworks][:instances][:filestore2][:ip]
else
	node.override[:drbd][:partner][:hostname] = node[:opsworks][:instances][:filestore1][:public_dns_name]
	node.override[:drbd][:partner][:ipaddress] = node[:opsworks][:instances][:filestore1][:ip]
end

node.override[:drbd][:primary][:fqdn] = node[:opsworks][:instances][primary_name][:public_dns_name]

node.override[:drbd][:server][:fqdn] = node[:opsworks][:instance][:public_dns_name]
node.override[:drbd][:server][:ipaddress] = node[:opsworks][:instance][:ip]

puts node[:drbd]

if ::File.exists?("/etc/drbd.conf")
    # update the config
    include_recipe "extended_drbd::drbd_inplace_upgrade"
else
    # perform fresh install and init of drbd volume
    include_recipe "extended_drbd::drbd_fresh_install"
end

