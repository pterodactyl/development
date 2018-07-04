
["vagrant-vbguest", "vagrant-hostmanager"].each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      raise plugin + " plugin is not installed. Hint: vagrant plugin install " + plugin
    end
end

Vagrant.configure("2") do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = true
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true

	# config.vm.network "private_network", ip: "192.168.10.1", virtualbox__intnet: true

	config.vm.define "app", primary: true do |app|
		app.vm.hostname = "app"
		app.vm.box = "bento/ubuntu-16.04"
		app.vm.box_check_update = true

		app.vm.synced_folder ".", "/vagrant", disabled: true
		app.vm.synced_folder "code/panel", "/srv/www", type: "nfs",
			mount_options: ["rw", "vers=3", "tcp", "fsc" ,"actimeo=1"],
			linux__nfs_options: ["rw", "no_subtree_check", "all_squash", "async"]

		app.vm.network "forwarded_port", guest: 80, host: 80
		app.vm.network :private_network, ip: "192.168.10.10"
		app.hostmanager.aliases = %w(pterodactyl.local)

		app.vm.provider :virtualbox do |vb|
			vb.gui = false
			vb.memory = 1024
			vb.cpus = 2

			vb.customize ["storagectl", :id, "--name", "SATA Controller", "--hostiocache", "on"]
    		vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    		vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    		vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    		vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    		vb.customize ["modifyvm", :id, "--ioapic", "on"]
		end

		app.vm.provision :shell, run: "once", inline: <<-SHELL
cat >> /etc/hosts <<EOF

# Vagrant
192.168.10.1 host
192.168.10.1 host.pterodactyl.local
# End Vagrant

192.168.1.202 services.pterodactyl.local
EOF
		SHELL

		app.vm.provision "file", source: "scripts/configs/pteroq.service", destination: "/tmp/.deploy/pteroq.service"
		app.vm.provision "file", source: "scripts/configs/pterodactyl.local.conf", destination: "/tmp/.deploy/pterodactyl.local.conf"

		app.vm.provision :shell, inline: <<-SHELL
			mv /tmp/.deploy/pteroq.service /etc/systemd/system/pteroq.service
			mv /tmp/.deploy/pterodactyl.local.conf /etc/nginx/sites-available/pterodactyl.local.conf
			rm -r /tmp/.deploy
		SHELL

		app.vm.provision :shell, path: "scripts/deploy_app.sh"

		app.vm.provision "setup", type: "shell", run: "never", inline: <<-SHELL
			cd /srv/www

			cp .env .env.bkup
			php artisan key:generate --force --no-interaction

			php artisan p:environment:setup --new-salt --author="you@example.com" --url="http://pterodactyl.local" --timezone="America/Los_Angeles" --cache=redis --session=redis --queue=redis --redis-host="host.pterodactyl.local" --no-interaction
			php artisan p:environment:database --host="host.pterodactyl.local" --database=panel --username=pterodactyl --password=pterodactyl --no-interaction
			php artisan p:environment:mail --driver=smtp --email="outgoing@example.com" --from="Pterodactyl Panel" --host="host.pterodactyl.local" --port=1025 --no-interaction

			php artisan migrate --seed
		SHELL
	end

	# Configure a mysql docker container.
	config.vm.define "mysql" do |mysql|
		mysql.vm.hostname = "mysql"
		mysql.vm.synced_folder ".", "/vagrant", disabled: true
		mysql.vm.synced_folder ".data/mysql", "/var/lib/mysql", create: true

		mysql.vm.network "forwarded_port", guest: 3306, host: 3306
		mysql.vm.network :private_network, ip: "192.168.10.11"
		mysql.hostmanager.aliases = %w(mysql.pterodactyl.local)

		mysql.vm.provider "docker" do |d|
			d.image = "mysql:5.7"
			d.ports = ["3306:3306"]
			d.cmd = [
				"--sql_mode=no_engine_substitution",
				"--innodb_buffer_pool_size=1G",
				"--innodb_log_file_size=256M",
				"--innodb_flush_log_at_trx_commit=0",
				"--innodb_flush_method=O_DIRECT",
				"--query_cache_type=1"
			]
			d.env = {
				"MYSQL_ROOT_PASSWORD": "root",
				"MYSQL_DATABASE": "panel",
				"MYSQL_USER": "pterodactyl",
				"MYSQL_PASSWORD": "pterodactyl"
			}
			d.remains_running = true
		end
	end

	# Create a docker container for mailhog which providers a local SMTP environment that avoids actually
	# sending emails to the address.
	config.vm.define "mailhog" do |mh|
		mh.vm.hostname = "mailhog"
		mh.vm.synced_folder ".", "/vagrant", disabled: true

		mh.vm.network "forwarded_port", guest: 1025, host: 1025
		mh.vm.network "forwarded_port", guest: 8025, host: 8025
		mh.vm.network :private_network, ip: "192.168.10.12"
		mh.hostmanager.aliases = %w(mailhog.pterodactyl.local)

		mh.vm.provider "docker" do |d|
			d.image = "mailhog/mailhog"
			d.ports = ["1025:1025", "8025:8025"]
			d.remains_running = true
		end
	end

	# Create a docker container for the redis server.
	config.vm.define "redis" do |redis|
		redis.vm.hostname = "redis"
		redis.vm.synced_folder ".", "/vagrant", disabled: true

		redis.vm.network "forwarded_port", guest: 6379, host: 6379
		redis.vm.network :private_network, ip: "192.168.10.13"
		redis.hostmanager.aliases = %w(redis.pterodactyl.local)

		redis.vm.provision :hostmanager

		redis.vm.provider "docker" do |d|
			d.image = "redis:4.0-alpine"
			d.ports = ["6379:6379"]
			d.remains_running = true
		end
	end
end