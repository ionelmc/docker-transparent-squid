#!/bin/bash -eux

if ! ip link add dummy0 type dummy &> /dev/null; then
    echo -e '\033[1;31mPrivileged mode was not enabled. \033[1;33mAdd \033[1;37m--privileged\033[1;33m to your command line.\033[0m'
    exit 1
fi
if ! ifconfig docker0 &> /dev/null; then
    echo -e '\033[1;31mHost networking was not enabled. \033[1;33mAdd \033[1;37m--net=host\033[1;33m to your command line.\033[0m'
    exit 1
fi

ip link delete dummy0 &> /dev/null

cp /etc/squid/squid.conf squid.conf
if [[ -n "$CACHE_SIZE" && -n "$CACHE_BACKEND" ]]; then
    echo "cache_dir $CACHE_BACKEND /var/cache/squid $CACHE_SIZE 16 256" >> squid.conf
fi

echo "http_port 3129 intercept" >> squid.conf
echo "maximum_object_size $CACHE_MAXIMUM_OBJECT_SIZE MB" >> squid.conf

echo "logfile_rotate 0" >> squid.conf
echo "cache_log stdio:/dev/stdout" >> squid.conf
echo "access_log stdio:/dev/stdout" >> squid.conf
echo "cache_store_log stdio:/dev/stdout" >> squid.conf

echo "Using this configuration:"
cat squid.conf | egrep -v '^(#|$)' | sort | sed 's/^/    /'

chown squid /dev/stdout

# make swap dirs
squid -Nz -f squid.conf

ifconfig

cleanup() {
    set +e
    iptables -t nat -D OUTPUT -p tcp -j HTTPFORCE
    iptables -t nat -F HTTPFORCE
    iptables -t nat -X HTTPFORCE
    set -e
}
trap cleanup EXIT
cleanup

# See: https://blog.bramp.net/post/2010/01/26/redirect-local-traffic-to-a-web-cache-with-iptables/
iptables -t nat -N HTTPFORCE
iptables -t nat -A HTTPFORCE --dst 127.0.0.1/8 -j RETURN
iptables -t nat -A HTTPFORCE -m owner --uid-owner squid -j RETURN
# alternative: iptables -t nat -A HTTPFORCE -p tcp --dport 80 -j DNAT --to $(hostname -i):3129
iptables -t nat -A HTTPFORCE -p tcp --dport 80 -j REDIRECT --to-port 3129
iptables -t nat -I OUTPUT 1 -p tcp -j HTTPFORCE

# run
squid -NdYC -f squid.conf

