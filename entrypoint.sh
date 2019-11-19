#!/usr/bin/env bash
set -e
sed -i "s~ENV_SERVER_NAME~${ENV_SERVER_NAME}~g" ${NGINX_CONF_DIR}/sites-enabled/app.conf
/usr/bin/supervisord