FROM php:8.3-apache-bullseye

USER root

# Add "install-php-extensions" script
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Add Node.js repository and install common development utilities
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    DEBIAN_FRONTEND=noninteractive apt update && \
    apt upgrade -y && \
    apt-get install -y \
    nodejs \
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
    rsync && \
    # Cleanup after initial installations
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions
# oci8 sometimes fails the first time, so try twice
RUN install-php-extensions oci8 || true
RUN install-php-extensions oci8 && \
    install-php-extensions \
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
    tokenizer && \
    # Remove build dependencies after installing PHP extensions
    apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Moosh
RUN wget https://moodle.org/plugins/download.php/34835/moosh_moodle45_2025020800.zip -O /tmp/moosh.zip \
    && unzip /tmp/moosh.zip -d /usr/local/bin/ \
    && rm /tmp/moosh.zip \
    && chmod +x /usr/local/bin/moosh \
    && ln -s /usr/local/bin/moosh /usr/bin/moosh \
    && rm -rf /tmp/*

# Moodle directory & permissions
RUN mkdir -p /var/www/moodledata && \
    chmod 777 /var/www/moodledata && \
    usermod -a -G root www-data && \
    chown -R www-data:www-data /var/www/html && \
    chown -R www-data:www-data /var/www/moodledata/

# Configure PHP
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
COPY ./php.ini "$PHP_INI_DIR/conf.d/php-custom.ini"

# Copy xdebug config
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Setup Cron for Moodle
RUN echo "*/1 * * * * /usr/local/bin/php /var/www/html/admin/cli/cron.php >/dev/null" >> /tmp/mycron && \
    crontab -u www-data /tmp/mycron && \
    rm /tmp/mycron

USER www-data

# Start Apache in the foreground
CMD ["apache2-foreground"]