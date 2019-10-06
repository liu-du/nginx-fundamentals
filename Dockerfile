FROM debian:buster

WORKDIR /tmp

RUN apt-get update && apt-get install -y wget build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev
RUN wget http://nginx.org/download/nginx-1.17.4.tar.gz 

RUN tar -zxvf nginx-1.17.4.tar.gz && rm nginx-1.17.4.tar.gz 

WORKDIR /tmp/nginx-1.17.4
RUN ./configure \
    --sbin-path=/usr/bin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-pcre --pid-path=/var/run/nginx.pid \
    --with-http_ssl_module 
RUN make && make install
RUN nginx -v

CMD [ "nginx" ]