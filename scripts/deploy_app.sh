#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

cp /tmp/.deploy/supervisor/pterodactyl.conf /etc/supervisor/conf.d/pterodactyl.conf
cp /tmp/.deploy/nginx/pterodactyl.test.conf /etc/nginx/sites-available/pterodactyl.test.conf

# Needed for FPM to start correctly.
mkdir -p /run/php

# Disable xdebug on the CLI for _MASSIVE_ performance improvement
phpdismod -s cli xdebug

cd /srv/www
chmod -R 755 storage/* bootstrap/cache
chown -R www-data:www-data storage

# Start out in a "this isn't a new install" mode
freshInstall=false
# If no environment file is found copy the example one and then generate the key.
if [ ! -f ".env" ]; then
	cp .env.example .env
fi

# Force this into local/debug mode
sed -i "s/APP_ENV=.*/APP_ENV=local/" .env
sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/" .env

composer install --no-interaction --prefer-dist --no-suggest --no-scripts --no-progress
php artisan config:clear

# Configure the cronjob
(crontab -l 2>/dev/null; echo "* * * * * php /srv/www/artisan schedule:run >> /dev/null 2>&1") | crontab -

# Create symlink
rm -f /root/app
ln -s /srv/www /root/app

# Configure OPCache
cat >> /etc/php/7.4/cli/conf.d/10-opcache.ini <<EOF
opcache.revalidate_freq = 0
opcache.max_accelerated_files = 11003
opcache.memory_consumption = 192
opcache.interned_strings_buffer = 16
opcache.fast_shutdown = 1
opcache.enable = 1
opcache.enable_cli = 1
EOF

cat >> /etc/php/7.4/fpm/conf.d/20-xdebug.ini <<EOF
xdebug.remote_enable = 1
xdebug.remote_host = host.docker.internal
xdebug.remote_port = 9000
xdebug.idekey = PHPSTORM
EOF

# Install development dependencies
yarn install --no-progress

# Cleanup
rm -rfv /var/www
rm -rv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/pterodactyl.test.conf /etc/nginx/sites-enabled/pterodactyl.test.conf

# Start processes
supervisorctl reread
supervisorctl update
supervisorctl start pteroq:*
supervisorctl restart nginx
