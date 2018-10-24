# transparent-squid

A transparent proxy for local use (will redirect requests to squid using iptables).

Suggested use:

    docker run -d --name=transparent-squid --restart=always --privileged --net=host -it ionelmc/transparent-squid

Optional extra arguments, examples:

* cache (set to `0` to disable caching, default: 10240mb):

      -e CACHE_SIZE=10240    
* cache maximum item size (default: 512mb):

      -e CACHE_MAXIMUM_OBJECT_SIZE=512
* cache backend (default: ufs):

      -e CACHE_BACKEND=aufs
* restrict cache domains (default: ""):

      -e CACHE_DOMAINS="ubuntu.com launchpad.net draios.com pgpool.net alpinelinux.org mongodb.org rabbitmq.com"
* avoid redirecting traffic to certain ips to squid (default: "127.0.0.1/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"):

      -e NOPROXY_IPS="127.0.0.1/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
