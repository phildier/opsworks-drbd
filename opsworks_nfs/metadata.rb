name             'opsworks_nfs'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures opsworks_nfs'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "iptables"
depends "extended_drbd"
depends "heartbeat3"
depends "nfs"
