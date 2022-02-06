FROM debian:11-slim

LABEL maintainer="dane@daneeveritt.com" \
	  description="Docker image allowing Pterodactyl Panel to run using Vagrant." \
	  org.opencontainers.image.source=https://github.com/pterodactyl/development

ENV DEBIAN_FRONTEND noninteractive \
    LANG C.UTF-8

USER root
RUN apt -y update \
    && apt -y --no-install-recommends install lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 curl sudo  \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
	&& curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list \
    && curl -sL https://packages.sury.org/php/apt.gpg | apt-key add - \
	&& apt -y update \
	&& apt -y upgrade \
	&& apt -y --no-install-recommends install \
        locales \
        iproute2 \
        iputils-ping \
        lsb-release \
        nginx \
        tar \
        unzip \
        git \
        supervisor \
        cron \
        nodejs \
        yarn \
        nano \
	&& apt -y --no-install-recommends install php8.0 \
		php8.0-cli \
		php8.0-common \
		php8.0-gd \
		php8.0-mysql \
		php8.0-mbstring \
		php8.0-bcmath \
		php8.0-xml \
		php8.0-fpm \
		php8.0-curl \
		php8.0-zip \
		php8.0-xdebug \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	&& apt autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

COPY entrypoint /usr/local/bin/entrypoint
COPY setup /usr/local/bin/setup
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY configs/pterodactyl.conf /etc/nginx/sites-available/pterodactyl.conf

RUN useradd -m pterodactyl \
    && usermod -a -g www-data -G sudo pterodactyl \
    && echo "pterodactyl  ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/pterodactyl \
    && chmod +x /usr/local/bin/setup \
    && chmod +x /usr/local/bin/entrypoint \
    && rm -rf /etc/nginx/sites-enabled/* \
    && ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/ \
    && phpdismod -s cli xdebug \
    && mkdir -p /var/run/php \
    && mkdir -p /var/www/html \
    && (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1") | crontab -

WORKDIR /var/www/html

EXPOSE 80
USER pterodactyl

ENTRYPOINT ["entrypoint"]
