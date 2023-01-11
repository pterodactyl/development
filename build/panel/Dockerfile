FROM debian:11-slim

LABEL maintainer="dane@daneeveritt.com" \
	  description="Local development environment for Pterodactyl Panel." \
	  org.opencontainers.image.source=https://github.com/pterodactyl/development

ENV DEBIAN_FRONTEND noninteractive
ENV LANG=C.UTF-8

USER root
RUN apt -y update \
    && apt -y --no-install-recommends install lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 curl sudo  \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
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
	&& apt -y --no-install-recommends install php8.1 \
		php8.1-cli \
		php8.1-common \
		php8.1-gd \
		php8.1-mysql \
		php8.1-mbstring \
		php8.1-bcmath \
		php8.1-xml \
		php8.1-fpm \
		php8.1-curl \
		php8.1-zip \
		php8.1-xdebug \
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
	&& apt autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

COPY entrypoint /usr/local/bin/entrypoint
COPY setup-pterodactyl /usr/local/bin/setup-pterodactyl
COPY configs/supervisord.conf /etc/supervisord.conf
COPY configs/pterodactyl.conf /etc/nginx/sites-available/pterodactyl.conf

RUN useradd -m pterodactyl \
    && usermod -a -g www-data -G sudo pterodactyl \
    && echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/sudoers \
    && chmod +x /usr/local/bin/setup-pterodactyl \
    && chmod +x /usr/local/bin/entrypoint \
    && rm -rf /etc/nginx/sites-enabled/* \
    && ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/ \
    && phpdismod -s cli xdebug \
    && mkdir -p /var/run/php \
    && mkdir -p /var/www/html \
    && (crontab -l 2>/dev/null; echo "* * * * * php /var/www/html/artisan schedule:run >> /dev/null 2>&1") | crontab -

WORKDIR /var/www/html

EXPOSE 80
EXPOSE 8080

ENTRYPOINT ["entrypoint"]
