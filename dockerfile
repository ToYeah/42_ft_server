FROM debian:buster

RUN		set -eux;\
		apt-get update;\
		apt-get install -y --no-install-recommends\
		wget \
		gnupg \
		lsb-release \
		nginx \
		mariadb-server \
		php-fpm

RUN		set -eux;\
		service mysql start;\
		mysql -u root -e "CREATE DATABASE wpdb";\
		mysql -u root -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '{wp0102}'";\
		mysql -u root -e "GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost'";\
		mysql -u root -e "FLUSH PRIVILEGES; EXIT";

RUN		set -eux;\
		wget --no-check-certificate -p /tmp -o latest.tar.gz https://wordpress.org/latest.tar.gz;\
		tar -xvzf -C /var/www/html/ latest.tar.gz;\
		rm latest.tar.gz;

COPY	./srcs/wp-config.php /var/www/html/wordpress;

RUN		