# Pterodactyl Vagrant Environment
This repository provides a basic vagrant environment suitable for development of Pterodactyl on your local machine.

### Getting Started
You'll need the following things installed on your machine.

* Vagrant
* VirtualBox
* Docker
* mkcert

You'll also need the following Vagrant plugins: `vagrant-hostmanager` and `vagrant-vbguest`

### First Run
These commands should be run if this will be your first time running Pterodactyl and you _do not already_ have a `.env` file configured.
```
vagrant up
vagrant up --provision-with setup app
```

### Subsequent Runs
Once you already have everything setup for the app, you can simply run `vagrant up`. If you only need the application, and have your own SQL server, redis, and mailhog (or some combination), you can run `vagrant up [boxes]` and replace `[boxes]` with the boxes to bring online.

### Daemons
There are VMs for both, the old and the new, daemons configured. They do not start automatically. You can start them using `vagrant up daemon` (for the nodejs one) and `vagrant up wings` (the golang one).

### Updating /etc/hosts
On your first run, and whenever the hostnames change, you'll have to run `vagrant hostmanager app --provider docker` to update your /etc/hosts file.
