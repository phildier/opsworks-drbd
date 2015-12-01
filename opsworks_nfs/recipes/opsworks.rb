
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

drbd_utils = "drbd-utils-8.9.4-1.x86_64.rpm"
s3_file "/root/#{drbd_utils}" do
	remote_path drbd_utils
	bucket "galaxydeploy"
end

rpm_package "drbd-utils" do
	source "/root/#{drbd_utils}"
end

# configure drbd
node.override[:drbd][:disk][:location] = physical_volume
node.override[:drbd][:packages] = []

if node[:opsworks][:instance][:hostname] == "filestore1" then
	partner_hostname = "filestore2"
	hostname = "filestore1"
	ip = node[:opsworks_nfs][:filestore1_ip] = "10.232.99.55"
else
	partner_hostname = "filestore1"
	hostname = "filestore2"
	ip = node[:opsworks_nfs][:filestore2_ip] = "10.165.178.246"
end

node.override[:drbd][:master] = ( hostname == primary_name )

node.override[:drbd][:partner][:hostname] = partner_hostname
node.override[:drbd][:partner][:ipaddress] = ip

node.override[:drbd][:primary][:fqdn] = primary_name

node.override[:drbd][:server][:fqdn] = hostname
node.override[:drbd][:server][:ipaddress] = ip

puts node[:drbd]

if ::File.exists?("/etc/drbd.conf")
    # update the config
    include_recipe "extended_drbd::drbd_inplace_upgrade"
else
    # perform fresh install and init of drbd volume
    include_recipe "extended_drbd::drbd_fresh_install"
end

