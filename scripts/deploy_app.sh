#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Install the dependencies for core software.
add-apt-repository -y ppa:ondrej/php
apt -y update && apt -y upgrade
apt -y install software-properties-common \
	php7.2 \
	php7.2-cli \
	php7.2-gd \
	php7.2-mysql \
	php7.2-pdo \
	php7.2-mbstring \
	php7.2-tokenizer \
	php7.2-bcmath \
	php7.2-xml \
	php7.2-fpm \
	php7.2-curl \
	php7.2-zip \
	php7.2-xdebug \
	nginx \
	curl \
	tar \
	unzip \
	git

# Install yarn and NodeJS for development purposes.
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
apt -y update && apt -y install nodejs yarn

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

cd /srv/www
chmod -R 755 storage/* bootstrap/cache

# Start out in a "this isn't a new install" mode
freshInstall=false
# If no environment file is found copy the example one and then generate the key.
if [ ! -f ".env" ]; then
	cp .env.example .env
fi

# Force this into local/debug mode
sed -i "s/APP_ENV=.*/APP_ENV=local/" .env
sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/" .env

composer install --no-interaction --prefer-dist --no-suggest --no-scripts
php artisan config:clear

# Configure the cronjob
(crontab -l 2>/dev/null; echo "* * * * * php /srv/www/artisan schedule:run >> /dev/null 2>&1") | crontab -

# Configure the process worker
systemctl enable pteroq.service
systemctl start pteroq

# Create symlink
rm -f /home/vagrant/app
ln -s /srv/www /home/vagrant/app

# Configure OPCache
cat >> /etc/php/7.2/cli/conf.d/10-opcache.ini <<EOF
opcache.revalidate_freq = 0
opcache.max_accelerated_files = 11003
opcache.memory_consumption = 192
opcache.interned_strings_buffer = 16
opcache.fast_shutdown = 1
opcache.enable = 1
opcache.enable_cli = 1
EOF

cat >> /etc/php/7.2/fpm/conf.d/20-xdebug.ini <<EOF
xdebug.remote_enable=1
xdebug.profiler_enable=1
EOF

# Install development dependencies
yarn install --no-progress

# Cleanup
rm -rfv /var/www
rm -rv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/pterodactyl.local.conf /etc/nginx/sites-enabled/pterodactyl.local.conf
service php7.2-fpm restart
service nginx restart