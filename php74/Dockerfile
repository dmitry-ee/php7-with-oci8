FROM php:7.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends -y \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libaio1 \
        libonig-dev \
        # for ssh2
        libssh2-1-dev \
        # pecl_httl / curl
        libcurl4-openssl-dev \
        libssl-dev \
        # soap
        libxml2-dev \
        # ldap
        libldap2-dev \
        # sqlsrv
        unixodbc-dev \
        # memcached
        libmemcached-dev \
        vim \
    && docker-php-ext-install -j$(nproc) iconv gettext iconv mbstring soap \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) ldap && \
    # MSSQL ODBC SETUP
    apt install -y gnupg2 --no-install-recommends && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt update && \
    env ACCEPT_EULA=Y apt-get install -y msodbcsql17 && \
    apt purge -y gnupg2 && \
    # MSSQL ODBC FIX FOR SQL SERVER2008
    # See: https://github.com/microsoft/msphpsql/issues/1056
    apt-get install -y --no-install-recommends openssl && \
    sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1.0',g' /etc/ssl/openssl.cnf && \
    sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf && \
    # CLEANUP
    apt -y autoremove && apt clean && rm -rf /var/lib/apt/lists/*

ARG INSTANTCLIENT_VER="12.2.0.1.0"
ARG SSH2_VER="1.2"
ARG PECL_HTTP_VER="3.2.3"
ARG RAPHF_VER="2.0.1"
ARG PROPRO_VER="2.1.0"
ARG SQLSRV_VER="5.8.0"
ARG MEMCACHED_VER="3.1.5"

COPY docker-php.conf /etc/apache2/conf-enabled/docker-php.conf

RUN printf "log_errors = On \nerror_log = /dev/stderr\n" > /usr/local/etc/php/conf.d/php-logs.ini

RUN a2enmod rewrite

# Oracle instantclient
COPY instantclient-basiclite-linux.x64-${INSTANTCLIENT_VER}.zip instantclient-sdk-linux.x64-${INSTANTCLIENT_VER}.zip instantclient-sqlplus-linux.x64-${INSTANTCLIENT_VER}.zip /tmp/

RUN unzip /tmp/instantclient-basiclite-linux.x64-${INSTANTCLIENT_VER}.zip -d /usr/local/ && \
    unzip /tmp/instantclient-sdk-linux.x64-${INSTANTCLIENT_VER}.zip -d /usr/local/ && \
    unzip /tmp/instantclient-sqlplus-linux.x64-${INSTANTCLIENT_VER}.zip -d /usr/local/ && \
    ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
    ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so && \
    ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
    rm -rf /tmp/instantclient* && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /root/.bashrc && \
    echo 'export LD_LIBRARY_PATH="/usr/local/instantclient"' >> /etc/apache2/envvars && \
    echo 'umask 002' >> /root/.bashrc && \
    echo 'instantclient,/usr/local/instantclient' | pecl install oci8 && \
    echo "extension=oci8.so" > /usr/local/etc/php/conf.d/php-oci8.ini && \
    # extentions
    cd /tmp && \
    # ssh2
    pecl install ssh2-${SSH2_VER} && echo "extension=ssh2.so" > /usr/local/etc/php/conf.d/php-ssh2.ini && \
    # raphf
    pecl install raphf-${RAPHF_VER} && echo "extension=raphf.so" > /usr/local/etc/php/conf.d/php-raphf.ini && \
    # propro
    pecl install propro-${PROPRO_VER} && echo "extension=propro.so" > /usr/local/etc/php/conf.d/php-propro.ini && \
    # pecl_http
    pecl install pecl_http-${PECL_HTTP_VER} && echo "extension=http.so" > /usr/local/etc/php/conf.d/php-http.ini && \
    # sqlsrv
    pecl install sqlsrv-${SQLSRV_VER}     && echo "extension=sqlsrv.so"     > /usr/local/etc/php/conf.d/php-sqlsrv.ini && \
    pecl install pdo_sqlsrv-${SQLSRV_VER} && echo "extension=pdo_sqlsrv.so" >> /usr/local/etc/php/conf.d/php-sqlsrv.ini && \
    # memcached
    pecl install memcached-${MEMCACHED_VER} && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/php-memcached.ini && \
    # ###
    rm -rf /tmp/*

COPY ports.conf /etc/apache2/ports.conf
COPY php-default.ini /usr/local/etc/php/conf.d/

RUN echo "<?php echo phpinfo(); ?>" > /var/www/html/phpinfo.php

EXPOSE 80 81
