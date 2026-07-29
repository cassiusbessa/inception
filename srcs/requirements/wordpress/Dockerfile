FROM alpine:3.20

RUN apk update && apk add --no-cache \
	php83 \
	php83-fpm \
	php83-mysqli \
	php83-json \
	php83-curl \
	php83-dom \
	php83-exif \
	php83-fileinfo \
	php83-mbstring \
	php83-openssl \
	php83-xml \
	php83-zip \
	php83-phar \
	php83-session \
	php83-tokenizer \
	php83-ctype \
	php83-iconv \
	php83-redis \
	curl \
	mariadb-client \
	&& rm -rf /var/cache/apk/*

RUN ln -sf /usr/bin/php83 /usr/bin/php \
	&& echo 'memory_limit = 512M' > /etc/php83/conf.d/99-memory.ini

# WP-CLI
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	-o /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp \
	&& printf '%s\n' '#!/bin/sh' 'exec php -d memory_limit=512M /usr/local/bin/wp.phar "$@"' > /usr/local/bin/wp-cli \
	&& mv /usr/local/bin/wp /usr/local/bin/wp.phar \
	&& mv /usr/local/bin/wp-cli /usr/local/bin/wp \
	&& chmod +x /usr/local/bin/wp

WORKDIR /var/www/html

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
	&& adduser -D -H -u 82 -G www-data www-data 2>/dev/null || true \
	&& mkdir -p /var/www/html \
	&& chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
