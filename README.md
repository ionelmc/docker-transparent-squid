# transparent-squid

A transparent proxy for local use (will redirect requests to squid using iptables).

Suggested use:

    docker run -d --name=transparent-squid --restart=always --privileged --net=host -it ionelmc/transparent-squid

Optional extra arguments:

* cache (set to `0` to disable caching):

      -e CACHE_SIZE=10240    
* cache maximum item size:

      -e CACHE_MAXIMUM_OBJECT_SIZE=512
* cache backend:

      -e CACHE_BACKEND=ufs
