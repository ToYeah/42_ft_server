FROM debian:buster

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
		supervisor

RUN		set -eux;\
		service mysql start;\
		mysql -u root -e "CREATE DATABASE wpdb";\
		mysql -u root -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'wppassword'";\
		mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost'";\
		mysql -u root -e "FLUSH PRIVILEGES";\
		mysql -u root -e "EXIT";

RUN		set -eux;\
		wget -O /tmp/latest.tar.gz --no-check-certificate  https://wordpress.org/latest.tar.gz;\
		tar -xvzf /tmp/latest.tar.gz -C /var/www/html/;\
		rm /tmp/latest.tar.gz;

COPY	./srcs/wp-config.php /var/www/html/wordpress/wp-config.php
COPY	./srcs/wordpress.conf /etc/nginx/sites-available/wordpress.conf
RUN		chown -R www-data:www-data /var/www/html/wordpress;\
		ln -s /etc/nginx/sites-available/wordpress.conf /etc/nginx/sites-enabled;\
		unlink /etc/nginx/sites-enabled/default;

#RUN		wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz;\
#		tar -xvzf phpmyadmin.tar.gz -C /usr/share/;\


COPY	./srcs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]