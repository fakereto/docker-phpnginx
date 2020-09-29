# docker-phpnginx
Docker image for PHP apps with Nginx

Hi, this repo, extend the docker-phpfpm image with nginx a and supervisor. for more information about the base image visit https://github.com/fakereto/docker-phpfpm and show all enviorement variables available to custom config.

WORKDIR /var/www/app/

PHP Version: 7.3-fpm with unix sockets
Nginx Version: 14.X
Supervisor for process management

This image have a volumen expose for you permanent app data in the directory: /var/www/app/ -> VOLUME /var/www/app/

And also expose the ports 443 and 80 for http/s request.
You need change the nginx file configuration for ssl

You can extend this image like you desire. 
Please you can send me a message on my github channel: https://github.com/fakereto

## Enviorement Variables

The enviorement variables add to this docker image build is ENV_SERVER_NAME. With this variable we can customize the server name directive for nginx configuration.
