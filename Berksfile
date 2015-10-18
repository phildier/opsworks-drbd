source "https://supermarket.getchef.com"

# external cookbooks
cookbook "nfs"
cookbook "apt"
cookbook "s3_file"
cookbook 'openssh'
cookbook 'wait'

group :site do
	# fork these
    cookbook 'heartbeat3', path: 'heartbeat3'
    cookbook 'extended_drbd', path: 'extended_drbd'
end
