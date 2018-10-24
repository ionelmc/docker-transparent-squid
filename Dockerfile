FROM alpine:3.8
RUN apk add --no-cache iptables squid dumb-init bash

VOLUME /var/cache/squid

ENV CACHE_SIZE=10240
ENV CACHE_MAXIMUM_OBJECT_SIZE=512
ENV CACHE_BACKEND=ufs
ENV CACHE_DOMAINS=""
ENV NOPROXY_IPS="127.0.0.1/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
COPY start.sh /
COPY squid.conf /

ENTRYPOINT ["dumb-init"]
CMD ["/start.sh"]
