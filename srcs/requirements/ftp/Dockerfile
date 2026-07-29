FROM alpine:3.20

RUN apk update && apk add --no-cache vsftpd openssl \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /var/www/html /var/run/vsftpd/empty \
	&& printf '%s\n' \
		'auth   required    pam_unix.so' \
		'account required  pam_unix.so' \
		'session required  pam_unix.so' \
		> /etc/pam.d/vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
