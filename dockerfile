FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
wget \
gnupg \
lsb-release \
nginx \
mariadb-server

RUN service mysql start && \
mysql -u root -p \
echo '\n' && \
CREATE DATABASE wpdb; create user 'wpuser'@'localhost' identified by '{wp0102}'; 



CMD tail -f /dev/null
