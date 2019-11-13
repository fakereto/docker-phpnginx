FROM fakereto/docker-phpfpm:7.3
MAINTAINER Andres Vejar <andresvejar@neubox.net>

ENV OS_LOCALE="en_US.UTF-8" \
    DEBIAN_FRONTEND=noninteractive
ENV LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
	NGINX_CONF_DIR=/etc/nginx

RUN	\
	BUILD_DEPS='software-properties-common wget gnupg' \
	&& apt-get update \
	&& apt-get install --no-install-recommends -y $BUILD_DEPS \
	&& apt-get install -y nginx nginx-extras \
	&& rm -rf ${NGINX_CONF_DIR}/sites-enabled/* ${NGINX_CONF_DIR}/sites-available/* \
	# Install supervisor
	&& apt-get install -y supervisor && mkdir -p /var/log/supervisor

	# Cleaning
RUN apt-get clean \
	&& apt-get purge -y --auto-remove --allow-remove-essential $BUILD_DEPS \
	&& rm -rf /var/lib/apt/lists/* \
	# Forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./app /var/www/app/

COPY ./configs/nginx.conf ${NGINX_CONF_DIR}/nginx.conf
COPY ./configs/custom_load.conf ${NGINX_CONF_DIR}/conf.d/custom_load.conf
COPY ./configs/app.conf ${NGINX_CONF_DIR}/sites-enabled/app.conf

RUN chown www-data:www-data /var/www/app/ -Rf

WORKDIR /var/www/app/
VOLUME /var/www/app/

EXPOSE 80 443

CMD ["/usr/bin/supervisord"]