FROM fakereto/docker-phpfpm:7.3
LABEL maintainer="Andres Vejar <andresvejar@neubox.net>"

ENV OS_LOCALE="en_US.UTF-8" \
    DEBIAN_FRONTEND=noninteractive \
	LANG=${OS_LOCALE} \
    LANGUAGE=${OS_LOCALE} \
    LC_ALL=${OS_LOCALE} \
	NGINX_CONF_DIR=/etc/nginx \
	NGINX_LOG_DIR=/var/log/nginx \
	SUPERVISOR_CONF_DIR=/etc/supervisor/conf.d \
	SUPERVISOR_LOG_DIR=/var/log/supervisor \
	ENV_SERVER_NAME=local.app.com

ENV NGINX_VERSION	1.14.*
ENV SUPERVISOR_VERSION	3.3.*

RUN	\
	BUILD_DEPS='software-properties-common wget gnupg' \
	&& apt-get update \
	&& apt-get install --no-install-recommends -y $BUILD_DEPS \
	&& apt-get install -y nginx=$NGINX_VERSION nginx-extras=$NGINX_VERSION \
	&& rm -rf ${NGINX_CONF_DIR}/sites-enabled/* ${NGINX_CONF_DIR}/sites-available/* \
	# Install supervisor
	&& apt-get install -y supervisor=${SUPERVISOR_VERSION} && mkdir -p $SUPERVISOR_LOG_DIR

	# Cleaning
RUN apt-get clean \
	&& apt-get purge -y --auto-remove --allow-remove-essential $BUILD_DEPS \
	&& rm -rf /var/lib/apt/lists/* \
	# Forward request and error logs to docker log collector
	&& ln -sf /dev/stdout ${NGINX_LOG_DIR}/access.log \
	&& ln -sf /dev/stderr ${NGINX_LOG_DIR}/error.log

VOLUME /var/www/app/
EXPOSE 80 443

COPY ./supervisord.conf ${SUPERVISOR_CONF_DIR}
COPY ./configs/nginx.conf ${NGINX_CONF_DIR}/nginx.conf
COPY ./configs/app.conf ${NGINX_CONF_DIR}/sites-enabled/app.conf

COPY ./app /var/www/app/

RUN sed -i "s~ENV_SERVER_NAME~${ENV_SERVER_NAME}~g" ${NGINX_CONF_DIR}/sites-enabled/app.conf \
    && chown www-data:www-data /var/www/app/ -Rf

WORKDIR /var/www/

# be sure nginx is properly passing to php-fpm and fpm is responding
HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost/ping || exit 1

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]