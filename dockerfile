FROM debian:buster

RUN apt-get update && apt-get install -y —no-install-recommends\
wget \
gnupg \
lsb-release \
nginx



CMD tail -f /dev/null
