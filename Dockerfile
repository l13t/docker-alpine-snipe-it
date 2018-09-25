FROM alpine:3.8

LABEL maintainer="Dmytro Prokhorenkov <liet@liet.kiev.ua>"

ENV PHP_FPM_USER="nginx"
ENV PHP_FPM_GROUP="nginx"
ENV PHP_FPM_LISTEN_MODE="0660"
ENV PHP_MEMORY_LIMIT="512M"
ENV PHP_MAX_UPLOAD="50M"
ENV PHP_MAX_FILE_UPLOAD="200"
ENV PHP_MAX_POST="100M"
ENV PHP_DISPLAY_ERRORS="On"
ENV PHP_DISPLAY_STARTUP_ERRORS="On"
ENV PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR"
ENV PHP_CGI_FIX_PATHINFO=0
ENV TIMEZONE="Europe/Berlin"

RUN apk add --no-cache \
        apache2-utils \
        bash \
        coreutils \
        curl \
        libxml2 \
        nginx \
        supervisor \
        tzdata \
        unzip \
        wget \
        php7 \
        php7-bcmath \
        php7-bz2 \
        php7-ctype \
        php7-curl \
        php7-dom \
        php7-fileinfo \
        php7-fpm \
        php7-gd \
        php7-gettext \
        php7-gmp \
        php7-iconv \
        php7-json \
        php7-mbstring \
        php7-mcrypt \
        php7-openssl \
        php7-pdo \
        php7-pdo_dblib \
        php7-pdo_mysql \
        php7-pdo_odbc \
        php7-pdo_pgsql \
        php7-phar \
        php7-session \
        php7-simplexml \
        php7-soap \
        php7-tokenizer \
        php7-xmlreader \
        php7-xmlrpc \
        php7-xmlwriter \
        php7-zip

RUN sed -i 's/variables_order = .*/variables_order = "EGPCS"/' /etc/php7/php.ini; \
        sed -i 's/user = nobody/user = nginx/; s/group = nobody/group = nginx/; s/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf; \
        echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf

RUN sed -i "s|;listen.owner\s*=\s*nobody|listen.owner = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.conf \
    && sed -i "s|;listen.group\s*=\s*nobody|listen.group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.conf \
    && sed -i "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" /etc/php7/php-fpm.conf \
    && sed -i "s|user\s*=\s*nobody|user = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.conf \
    && sed -i "s|group\s*=\s*nobody|group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.conf \
    && sed -i "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.conf \
    && sed -i 's/include\ \=\ \/etc\/php7\/fpm.d\/\*.conf/\;include\ \=\ \/etc\/php7\/fpm.d\/\*.conf/g' /etc/php7/php-fpm.conf

RUN sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php7/php.ini \
    && sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" /etc/php7/php.ini \
    && sed -i "s|error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = ${PHP_ERROR_REPORTING}|i" /etc/php7/php.ini \
    && sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini \
    && sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" /etc/php7/php.ini \
    && sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini \
    && sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini \
    && sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" /etc/php7/php.ini

RUN rm -rf /etc/localtime \
    && ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    && sed -i "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" /etc/php7/php.ini

ARG SNIPE_IT_VER

RUN if [ -z ${SNIPE_IT_VER+x} ]; then \
 	SNIPE_IT_VER=$(curl -sX GET "https://api.github.com/repos/snipe/snipe-it/releases/latest" \
        | awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    wget -q -O /tmp/snipeit.tar.gz "https://github.com/snipe/snipe-it/archive/${SNIPE_IT_VER}.tar.gz"; \
    mkdir -p /var/www/html; \
    tar xf /tmp/snipeit.tar.gz -C /var/www/html/ --strip-components=1; \
    rm -fr /tmp/snipeit.tar.gz

RUN cd /tmp; \
    curl -sS https://getcomposer.org/installer | php; \
    mv /tmp/composer.phar /usr/local/bin/composer; \
    composer install -d /var/www/html; \
    mkdir -p /defaults; \
    mv "/var/www/html/storage" /defaults/; \
    mv "/var/www/html/public/uploads" /defaults/; \
    rm -rf /root/.composer /tmp/*; \
    rm -rf /etc/nginx/conf.d/default.conf /etc/nginx/nginx.conf

COPY docker.env /var/www/html/.env

RUN chown -R nginx:nginx /var/www/html; \
    mkdir -p /config/logs/

COPY nginx-snipe-it.conf /etc/nginx/conf.d/snipe-it.conf
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

VOLUME ["/config"]
