curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

# Install dependencies and start supervisor
sudo apt install -y --no-install-recommends nginx nodejs yarn supervisor
sudo /usr/bin/supervisord

# Copy over deployment specific files.
sudo cp /tmp/.deploy/supervisor/pterodocs.conf /etc/supervisor/conf.d/pterodocs.conf
sudo cp /tmp/.deploy/nginx/pterodocs.test.conf /etc/nginx/sites-available/pterodocs.test.conf

cd ~/docs
yarn

sudo rm -f /srv/documentation
sudo ln -s ~/docs /srv/documentation

# Configure and restart nginx
sudo rm -rfv /var/www
sudo rm -rfv /etc/nginx/sites-enabled/*
sudo ln -s /etc/nginx/sites-available/pterodocs.test.conf /etc/nginx/sites-enabled/pterodocs.test.conf

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl restart nginx