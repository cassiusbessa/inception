FROM alpine:3.20

RUN apk update && apk add --no-cache redis \
	&& rm -rf /var/cache/apk/*

COPY conf/redis.conf /etc/redis.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
	&& mkdir -p /data \
	&& chown redis:redis /data

EXPOSE 6379

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
