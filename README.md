# transparent-squid

A transparent proxy for local use (will redirect requests to squid using iptables).

Note that HTTPS is not cached, only HTTP going on on port 80 is.
While technically possible (squid's "ssl bump" feature)
it would mean all clients would need to allow a custom certificate authority.

Suggested use:

    docker run --name=transparent-squid --restart=unless=stopped \
               --privileged --net=host -d ionelmc/transparent-squid

If you wanna run this on your desktop (not in a non-bridged vm where you
wouldn't get traffic from outside world) you might want to restrict ips
from which squid allows requests:

    docker run --name=transparent-squid --restart=unless=stopped \
                -e LOCALNET_IPS="172.16.0.0/12" \
                --privileged --net=host -d ionelmc/transparent-squid


If you only wanna cache package repositories:

    docker run --name=transparent-squid --restart=unless=stopped \
               --privileged --net=host -d -e \
               CACHE_DOMAINS="ubuntu.com launchpad.net draios.com pgpool.net alpinelinux.org mongodb.org rabbitmq.com debian.org postgresql.org" \
               ionelmc/transparent-squid


Optional configuration, examples:

* cache (set to `0` to disable caching, default: 10240mb):

      -e CACHE_SIZE=10240    
* cache maximum item size (default: 512mb):

      -e CACHE_MAXIMUM_OBJECT_SIZE=512
* cache backend (default: ufs):

      -e CACHE_BACKEND=aufs
* restrict cache domains (default: ""):

      -e CACHE_DOMAINS="ubuntu.com launchpad.net draios.com pgpool.net alpinelinux.org mongodb.org rabbitmq.com debian.org postgresql.org"
* avoid redirecting traffic to certain ips to squid (default: "127.0.0.1/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"):

      -e NOPROXY_IPS="127.0.0.1/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
* only allow proxy requests from certain ips (default: "10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 fc00::/7 fe80::/10")

      -e LOCALNET_IPS="172.16.0.0/12"
