#!/bin/bash

echo "Disabling eth0 tx checksum offload ..."
/sbin/ethtool --offload eth0 tx off
exit 0
