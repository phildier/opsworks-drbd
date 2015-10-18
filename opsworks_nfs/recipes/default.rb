
directory "/export"

# install iptables tool
include_recipe "iptables"

if ::File.exists?("/etc/drbd.conf")
	# update the config
	include_recipe "extended_drbd::drbd_inplace_upgrade"
else
	# perform fresh install and init of drbd volume
	include_recipe "extended_drbd::drbd_fresh_install"
end

# install and configure nfs
include_recipe "nfs::server4"

# install and configure heartbeat
include_recipe "heartbeat3"

# create nfs export
nfs_export "/exports" do
	network "10.0.0.0/8"
	writeable true
	sync false
	options [
		"fsid=0",
		"no_subtree_check"
	]
end
