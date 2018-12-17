apt -y update && apt -y install apt-transport-https

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -

# Install dependencies and start supervisor
apt install -y --no-install-recommends nginx nodejs yarn supervisor
/usr/bin/supervisord

# Copy over deployment specific files.
cp /tmp/.deploy/supervisor/pterodocs.conf /etc/supervisor/conf.d/pterodocs.conf
cp /tmp/.deploy/nginx/pterodocs.test.conf /etc/nginx/sites-available/pterodocs.test.conf

cd /srv/documentation
yarn add vuepress

rm -f ~/docs
ln -s /srv/documentation ~/docs

# Configure and restart nginx
rm -rfv /var/www
rm -rfv /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/pterodocs.test.conf /etc/nginx/sites-enabled/pterodocs.test.conf

supervisorctl reread
supervisorctl update
supervisorctl restart nginx