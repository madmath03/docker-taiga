FROM python:3.6-alpine3.7

# Specify LANG to ensure python installs locals properly
ENV LANG C \
    LANG en_US.UTF-8 \
    LC_TYPE en_US.UTF-8

# Install necessary applications
RUN apk add --update --no-cache \
    git \
    gettext \
    ca-certificates \
    nginx \
    postgresql-dev \
    libffi-dev \
    gcc \
    musl-dev \
    libxml2-dev \
    libxslt-dev \
    jpeg-dev \
    curl

# Preparing Nginx data
COPY taiga-back /usr/src/taiga-back
COPY taiga-front-dist/ /usr/src/taiga-front-dist
COPY conf/locale.gen /etc/locale.gen

# Setup Nginx configurations
RUN mkdir /run/nginx
RUN sed -i "s/user www-data/user root/g" /etc/nginx/nginx.conf
RUN sed -i "s/worker_connections 768/worker_connections 1024/g" /etc/nginx/nginx.conf
RUN sed -i "s/ssl_session_cache shared:SSL:2m;/ssl_session_cache shared:SSL:10m;/g" /etc/nginx/nginx.conf

RUN rm  /etc/nginx/conf.d/default.conf
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled
RUN sed -i '/include \/etc\/nginx\/conf\.d\/\*\.conf;/a \
        include /etc/nginx/sites-enabled/*;' \
        /etc/nginx/nginx.conf
COPY conf/nginx/sites-available/* /etc/nginx/sites-available/
COPY conf/nginx/snippets/*        /etc/nginx/snippets/

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

# Setup symbolic links for configuration files
RUN mkdir -p /taiga
COPY conf/taiga/local.py /taiga/local.py
COPY conf/taiga/docker.py /taiga/docker.py
COPY conf/taiga/conf.json /taiga/conf.json
RUN ln -s /taiga/local.py /usr/src/taiga-back/settings/local.py
RUN ln -s /taiga/docker.py /usr/src/taiga-back/settings/docker.py
RUN ln -s /taiga/conf.json /usr/src/taiga-front-dist/dist/conf.json

# Backwards compatibility
RUN mkdir -p /usr/src/taiga-front-dist/dist/js/
RUN ln -s /taiga/conf.json /usr/src/taiga-front-dist/dist/js/conf.json

WORKDIR /usr/src/taiga-back
RUN pip install --no-cache-dir -r requirements.txt

# Define default env vars
ENV TAIGA_SSL False
ENV TAIGA_SSL_BY_REVERSE_PROXY False
ENV TAIGA_ENABLE_EMAIL False
ENV TAIGA_HOSTNAME localhost
ENV TAIGA_SECRET_KEY "!!!REPLACE-ME-j1598u1J^U*(y251u98u51u5981urf98u2o5uvoiiuzhlit3)!!!"

EXPOSE 80 443
VOLUME /usr/src/taiga-back/media

# Health checks
HEALTHCHECK CMD curl --fail http://localhost/conf.json || exit 1
HEALTHCHECK CMD curl --fail http://localhost/api/v1/ || exit 1
HEALTHCHECK CMD curl --fail http://localhost || exit 1


COPY scripts /scripts
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["gunicorn", "-w 3", "-t 60", "--pythonpath=.", "-b 127.0.0.1:8000", "taiga.wsgi"]
