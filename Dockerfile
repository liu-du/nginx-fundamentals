FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

# Install utilities, build deps, php, supervisor and supervisor-stdout 
RUN apt-get update \
    && apt-get install -y \
    procps wget \
    build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev \
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
    && make \
    && make install \
    && cd /app && rm -rf nginx-1.17.4

RUN nginx -v

# Copy configs for nginx and supervisor
COPY conf/nginx.conf /etc/nginx/nginx.conf 
COPY conf/supervisor.conf /etc/supervisord.conf
COPY conf/entrypoint.sh /usr/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]