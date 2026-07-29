FROM alpine:3.20

RUN apk update && apk add --no-cache nginx \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /var/www/static /run/nginx

COPY site/ /var/www/static/
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
