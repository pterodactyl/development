#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

sudo cp /tmp/.deploy/supervisor/pterodactyl.conf /etc/supervisor/conf.d/pterodactyl.conf
sudo cp /tmp/.deploy/nginx/pterodactyl.test.conf /etc/nginx/sites-available/pterodactyl.test.conf

# Needed for FPM to start correctly.
sudo mkdir -p /run/php

# Disable xdebug on the CLI for _MASSIVE_ performance improvement
sudo phpdismod -s cli xdebug

cd /home/vagrant/app
sudo chown -R vagrant:vagrant *
sudo chown -R www-data:vagrant storage
sudo chmod -R 775 storage/* bootstrap/cache

# Start out in a "this isn't a new install" mode
freshInstall=false
# If no environment file is found copy the example one and then generate the key.
if [ ! -f ".env" ]; then
	cp .env.example .env
fi

# Force this into local/debug mode
sed -i "s/APP_ENV=.*/APP_ENV=local/" .env
sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/" .env

composer install --no-interaction --prefer-dist --no-scripts --no-progress
php artisan config:clear

# Configure the cronjob
(crontab -l 2>/dev/null; echo "* * * * * php /home/vagrant/app/artisan schedule:run >> /dev/null 2>&1") | crontab -

# Create symlink
sudo rm -f /srv/www
sudo ln -s /home/vagrant/app /srv/www

# Configure OPCache
sudo cat | sudo tee -a /etc/php/8.0/cli/conf.d/10-opcache.ini > /dev/null <<EOF
opcache.revalidate_freq = 0
opcache.max_accelerated_files = 11003
opcache.memory_consumption = 192
opcache.interned_strings_buffer = 16
opcache.fast_shutdown = 1
opcache.enable = 1
opcache.enable_cli = 1
EOF

sudo cat | sudo tee -a /etc/php/8.0/fpm/conf.d/20-xdebug.ini > /dev/null <<EOF
xdebug.remote_enable = 1
xdebug.remote_host = host.docker.internal
xdebug.remote_port = 9000
xdebug.idekey = PHPSTORM
EOF

# Install development dependencies
yarn install --no-progress

# Cleanup
sudo rm -rfv /var/www
sudo rm -rv /etc/nginx/sites-enabled/*
sudo ln -s /etc/nginx/sites-available/pterodactyl.test.conf /etc/nginx/sites-enabled/pterodactyl.test.conf

# Start processes
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start pteroq:*
sudo supervisorctl restart nginx

echo "done."
