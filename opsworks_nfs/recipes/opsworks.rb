
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
	hostname = "filestore1"
	ip = node[:opsworks_nfs][:filestore1][:private_ip]
	partner_hostname = "filestore2"
	partner_ip = node[:opsworks_nfs][:filestore2][:private_ip]
else
	hostname = "filestore2"
	ip = node[:opsworks_nfs][:filestore2][:private_ip]
	partner_hostname = "filestore1"
	partner_ip = node[:opsworks_nfs][:filestore1][:private_ip]
end

node.override[:drbd][:master] = ( hostname == primary_name )

node.override[:drbd][:partner][:hostname] = partner_hostname
node.override[:drbd][:partner][:ipaddress] = partner_ip

node.override[:drbd][:primary][:fqdn] = primary_name

node.override[:drbd][:server][:hostname] = hostname
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

# install nfs server
node.override[:nfs][:v4] = "yes"
include_recipe "nfs::server4"

# configure heartbeat
node.override[:heartbeat][:ha_cf][:initdead] = 30
node.override[:heartbeat][:ha_cf][:keepalive] = 1
node.override[:heartbeat][:ha_cf][:deadtime] = 10
node.override[:heartbeat][:ha_cf][:deadping] = 10
node.override[:heartbeat][:ha_cf][:warntime] = 5
node.override[:heartbeat][:ha_cf][:auto_failback] = "on"
node.override[:heartbeat][:ha_cf][:logfacility] = "local0"
node.override[:heartbeat][:ha_cf][:node] = ["filestore1","filestore2"]
node.override[:heartbeat][:ha_cf][:ucast] = "eth0 #{partner_ip}"

node.override[:heartbeat][:haresources] = [
	{
		"node" => "filestore1",
		"resources" => [
			"drbddisk::data",
			"Filesystem::/dev/drbd0::/export",
			"nfs-kernel-server"
		]
	}
]

node.override[:heartbeat][:services] = ["nfs-kernel-server"]

include_recipe "heartbeat3"
