FROM alpine:edge
LABEL maintainer="DeVOps"

# Install packages
RUN apk add --update && \ 
apk --no-cache add nodejs-current php7 php7-fpm php7-mysqli php7-json php7-curl php7-cli \
    php7-xml php7-intl php7-common openssh\
    php7-gd nginx supervisor curl \
    && rm  -rf /tmp/* /var/cache/apk/*
ADD docker-entrypoint.sh /usr/local/bin

#make sure we get fresh keys
RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key 

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add application
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
COPY src/ /var/www/html/

EXPOSE 22 80 443
CMD docker-entrypoint.sh && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf && /usr/sbin/sshd -D