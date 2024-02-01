#!/bin/bash
#
# configure mpls routing capabilities on host for containers

_mpls_sysctl_file="${MPLS_SYSCTL_FILE:-/etc/sysctl.d/90-mpls-router.conf}"


if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as sudo.."
    exit 1
fi

modprobe mpls_router
modprobe mpls_iptunnel

lsmod | grep mpls

cat > "${_mpls_sysctl_file}" << _EOH1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.tcp_l3mdev_accept = 1
net.ipv4.udp_l3mdev_accept = 1
net.mpls.conf.lo.input = 1
net.mpls.default_ttl = 255
net.mpls.ip_ttl_propagate = 1
net.mpls.platform_labels = 1048575
_EOH1
sysctl -p "${_mpls_sysctl_file}"
