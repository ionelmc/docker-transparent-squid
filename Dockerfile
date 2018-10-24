FROM alpine:3.8
RUN apk add --no-cache iptables squid dumb-init bash

VOLUME /var/cache/squid

ENV CACHE_SIZE=10240
ENV CACHE_MAXIMUM_OBJECT_SIZE=512
ENV CACHE_BACKEND=ufs
COPY start.sh /
COPY squid.conf /

ENTRYPOINT ["dumb-init"]
CMD ["/start.sh"]
