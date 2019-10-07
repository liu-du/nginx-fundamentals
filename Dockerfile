FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

# Install utilities, build deps, php, supervisor and supervisor-stdout 
RUN apt-get update \
    && apt-get install -y \
    procps wget curl apache2-utils siege \
    build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev \
    python-setuptools python-pip \
    php-fpm \
    && mkdir -p /run/php/ \
    && pip install supervisor supervisor-stdout

WORKDIR /app

# Build nginx from source
RUN wget http://nginx.org/download/nginx-1.17.4.tar.gz \
    && tar -zxvf nginx-1.17.4.tar.gz \
    && rm nginx-1.17.4.tar.gz \
    && cd /app/nginx-1.17.4 \
    && ./configure \
    --sbin-path=/usr/bin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_image_filter_module=dynamic \
    --modules-path=/etc/nginx/modules \
    && make \
    && make install \
    && cd /app && rm -rf nginx-1.17.4

RUN nginx -V

# Generate self-signed certificate, certificate key and DH param file
RUN mkdir /etc/nginx/ssl \
    && openssl req -x509 -nodes \
    -days 10 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/self.key \
    -out /etc/nginx/ssl/self.crt \
    -subj "/C=AU/ST=NSW/L=Sydney/O=jimmy/CN=duliu.me" \
    && openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 

# Copy configs for nginx and supervisor
COPY conf/nginx.conf /etc/nginx/nginx.conf 
COPY conf/supervisor.conf /etc/supervisord.conf
COPY conf/entrypoint.sh /usr/bin/entrypoint.sh

# Generate username/password for basic auth
RUN htpasswd -bc /etc/nginx/.htpasswd jimmy password

EXPOSE 80 443
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]