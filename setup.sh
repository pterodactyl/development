currentDirectory=$(cwd)
cd /tmp

vagrant plugin install vagrant-vbguest
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-notify-forwarder

cd $currentDirectory
git clone https://github.com/pterodactyl/panel.git code/panel
