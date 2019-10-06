FROM debian:buster

WORKDIR /tmp

RUN apt-get update \
    && apt-get install -y \
    procps wget \
    build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev \
    python-setuptools python-pip \
    && pip install supervisor supervisor-stdout

RUN wget http://nginx.org/download/nginx-1.17.4.tar.gz \
    && tar -zxvf nginx-1.17.4.tar.gz \
    && rm nginx-1.17.4.tar.gz \
    && cd /tmp/nginx-1.17.4 \
    && ./configure \
    --sbin-path=/usr/bin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --with-pcre \
    --with-http_ssl_module \
    && make \
    && make install

RUN nginx -v

COPY conf/supervisor.conf /etc/supervisord.conf
COPY conf/entrypoint.sh /usr/bin/entrypoint.sh

EXPOSE 80
ENTRYPOINT [ "/usr/bin/entrypoint.sh" ]