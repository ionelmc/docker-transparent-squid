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

cp /squid.conf patched-squid.conf
if [[ -n "$CACHE_SIZE" && "$CACHE_SIZE" != "0" && -n "$CACHE_BACKEND" ]]; then
    echo "cache_dir $CACHE_BACKEND /var/cache/squid $CACHE_SIZE 16 256" >> patched-squid.conf
    echo "maximum_object_size $CACHE_MAXIMUM_OBJECT_SIZE MB" >> patched-squid.conf
fi
if [[ -n "$CACHE_DOMAINS" ]]; then
    for domain in $CACHE_DOMAINS; do
        echo "acl cached_domains dstdomain .$domain" >> patched-squid.conf
    done
    echo "cache deny !cached_domains" >> patched-squid.conf
fi
for mask in $LOCALNET_IPS; do
    echo "acl localnet src $mask" >> patched-squid.conf
done

echo "Using this configuration:"
cat squid.conf | egrep -v '^(#|$)' | sort | sed 's/^/    /'

chown squid /dev/stdout

# make swap dirs
squid -Nz -f patched-squid.conf

ifconfig | egrep '^\S|inet'

cleanup() {
    set +e
    iptables -t nat -D OUTPUT -p tcp --syn --dport 80 -j REDIRECT --to-port 3129
    iptables -t nat -D PREROUTING -p tcp --syn --dport 80 -j REDIRECT --to-port 3129
    iptables -t nat -D OUTPUT -m owner --uid-owner squid -j RETURN
    for mask in $NOPROXY_IPS; do
        iptables -t nat -D OUTPUT --dst $mask -j RETURN
        iptables -t nat -D PREROUTING --dst $mask -j RETURN
    done
    set -e
}
trap cleanup EXIT
cleanup

# See:
#   https://blog.bramp.net/post/2010/01/26/redirect-local-traffic-to-a-web-cache-with-iptables/
#   https://blog.jessfraz.com/post/routing-traffic-through-tor-docker-container/
iptables -t nat -I OUTPUT 1 -p tcp --syn --dport 80 -j REDIRECT --to-port 3129
iptables -t nat -I PREROUTING 1 -p tcp --syn --dport 80 -j REDIRECT --to-port 3129
iptables -t nat -I OUTPUT 1 -m owner --uid-owner squid -j RETURN
for mask in $NOPROXY_IPS; do
    iptables -t nat -I OUTPUT 1 --dst $mask -j RETURN
    iptables -t nat -I PREROUTING 1 --dst $mask -j RETURN
done

# run
squid -NdYC -f patched-squid.conf

