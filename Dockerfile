FROM php:8.3-apache-bullseye

USER root

# Add "install-php-extensions" script
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Update and install some utils
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    apt upgrade -y && \
    apt-get update && \
    apt-get install -y \
    zip \
    unzip \
    wget \
    curl \
    nano \
    vim \
    less \
    git \
    telnet \
    iputils-ping \
    net-tools \
    dnsutils \
    htop \
    lsof \
    procps \
    cron \
    tree \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    jq \
    bash-completion \
    locales \
    rsync


# oci8 sometimes fail the first time
RUN install-php-extensions oci8 || true
RUN install-php-extensions oci8
RUN install-php-extensions \
    xdebug \
    zip \
    gd \
    intl \
    soap \
    exif \
    pgsql \
    pdo_pgsql \
    mysqli \
    pdo_mysql \
    curl \
    mbstring \
    json \
    bcmath \
    sodium \
    redis \
    memcached \
    xmlrpc \
    ldap \
    imagick \
    sqlsrv \
    openssl \
    tokenizer

    
#Install moosh
RUN wget https://moodle.org/plugins/download.php/34835/moosh_moodle45_2025020800.zip -O /tmp/moosh.zip \
    && unzip /tmp/moosh.zip -d /usr/local/bin/ \
    && rm /tmp/moosh.zip \
    && chmod +x /usr/local/bin/moosh \
    && ln -s /usr/local/bin/moosh /usr/bin/moosh

#Moodle directory & perm
RUN mkdir /var/www/moodledata && chmod 777 /var/www/moodledata
RUN usermod -a -G root www-data && chown -R www-data:www-data /var/www/html && chown -R www-data:www-data /var/www/moodledata/

#Config PHP
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY ./php.ini "$PHP_INI_DIR/conf.d/php-custom.ini"

#Intsall nvm and nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt install -y nodejs
RUN node -v && npm -v
#Copy xdebug config
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini


# Cron
RUN echo "*/1 * * * * /usr/local/bin/php /var/www/html/admin/cli/cron.php >/dev/null" >> /tmp/mycron &&  crontab -u www-data /tmp/mycron && rm /tmp/mycron

USER www-data

# Start Apache
CMD ["apache2-foreground"]
