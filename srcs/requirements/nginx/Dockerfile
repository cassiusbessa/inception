FROM alpine:3.20

ARG DOMAIN_NAME=caqueiro.42.fr

RUN apk update && apk add --no-cache \
	nginx \
	openssl \
	&& rm -rf /var/cache/apk/*

RUN mkdir -p /etc/nginx/ssl /var/www/html /run/nginx \
	&& openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/inception.key \
		-out /etc/nginx/ssl/inception.crt \
		-subj "/C=BR/ST=SP/L=SaoPaulo/O=42/OU=Inception/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
