FROM debian:buster

#apt install
RUN		set -eux;\
		apt-get update;\
		apt-get install -y --no-install-recommends\
		wget \
		gnupg \
		lsb-release \
		nginx \
		mariadb-server \
		php-fpm \
		php-mysql \
		supervisor \
		php-mbstring \
		openssl


#entrykit install
ENV		ENTRYKIT_VERSION 0.4.0

RUN		wget --no-check-certificate https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
		&& tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
		&& rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
		&& mv entrykit /bin/entrykit \
		&& chmod +x /bin/entrykit \
		&& entrykit --symlink

COPY	./srcs/ftserver.conf.tmpl /etc/nginx/sites-available/ftserver.conf.tmpl

ENTRYPOINT [ "render", "/etc/nginx/sites-available/ftserver.conf", "--"]


#mysql setup
RUN		set -eux;\
		service mysql start;\
		mysql -u root -e "CREATE DATABASE wpdb";\
		mysql -u root -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword'";\
		mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost'";\
		mysql -u root -e "FLUSH PRIVILEGES";\
		mysql -u root -e "EXIT";


#wordpress setup
RUN		set -eux;\
		wget -O /tmp/latest.tar.gz --no-check-certificate https://wordpress.org/latest.tar.gz;\
		tar -xvzf /tmp/latest.tar.gz -C /var/www/html/;\
		rm /tmp/latest.tar.gz;

COPY	./srcs/wp-config.php /var/www/html/wordpress/wp-config.php

RUN		chown -R www-data:www-data /var/www/html/wordpress;\
		ln -s /etc/nginx/sites-available/ftserver.conf /etc/nginx/sites-enabled;\
		unlink /etc/nginx/sites-enabled/default;


#phpMyAdmin setup
RUN		wget -O /tmp/phpmyadmin.tar.gz --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/4.9.7/phpMyAdmin-4.9.7-all-languages.tar.gz;\
		tar -xvzf /tmp/phpmyadmin.tar.gz -C /var/www/html/;\
		mv /var/www/html/phpMyAdmin-4.9.7-all-languages /var/www/html/phpmyadmin;\
		mkdir -p /var/lib/phpmyadmin/tmp;\
		chown -R www-data:www-data /var/lib/phpmyadmin/tmp;

COPY	./srcs/config.inc.php /var/www/html/phpmyadmin/config.inc.php


#ssl setup
RUN		 mkdir /etc/nginx/ssl;\
		 openssl genrsa -out /etc/nginx/ssl/server.key 2048;\
		 openssl req -new -subj /CN=localhost -key /etc/nginx/ssl/server.key -out /etc/nginx/ssl/server.csr;\
		 openssl x509 -days 3650 -req -signkey /etc/nginx/ssl/server.key -in /etc/nginx/ssl/server.csr -out /etc/nginx/ssl/server.crt;

#supervisor setup
COPY	./srcs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]