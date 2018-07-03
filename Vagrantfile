
["vagrant-bindfs", "vagrant-vbguest", "vagrant-hostmanager"].each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      raise plugin + ' plugin is not installed. Hint: vagrant plugin install ' + plugin
    end
end

Vagrant.configure("2") do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = true
	config.hostmanager.ignore_private_ip = true
	config.hostmanager.include_offline = true

	config.vm.define "app", primary: true do |app|
		app.vm.hostname = 'app'
		app.vm.box = 'bento/ubuntu-16.04'
		app.vm.box_check_update = true

		app.vm.synced_folder ".", "/vagrant", disabled: true
		app.vm.synced_folder "code/panel", "/srv/www", owner: "www-data", group: "www-data"

		app.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "127.0.0.1"
		app.vm.network :private_network, ip: "192.168.10.10"
		app.hostmanager.aliases = %w(pterodactyl.local)

		app.vm.provider "virtualbox" do |box|
			box.gui = false
			box.memory = 512
			box.customize [
        		"storagectl", :id,
        		"--name", "SATA Controller",
        		"--hostiocache", "on"
    		]
		end

		app.vm.provision :shell, inline: <<-SHELL
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
	end

	config.vm.define "mysql" do |mysql|
		mysql.vm.hostname = 'mysql'
		mysql.vm.synced_folder ".", "/vagrant", disabled: true
		mysql.vm.synced_folder ".data/mysql", "/var/lib/mysql", create: true

		mysql.vm.network "forwarded_port", guest: 3306, host: 3306, host_ip: "127.0.0.1"
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
				"--innodb_fliush_method=O_DIRECT",
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

	config.vm.define "mailhog" do |mh|
		mh.vm.hostname = 'mailhog'
		mh.vm.synced_folder ".", "/vagrant", disabled: true
		
		mh.vm.network "forwarded_port", guest: 1025, host: 1025, host_ip: "127.0.0.1"
		mh.vm.network "forwarded_port", guest: 8025, host: 8025, host_ip: "127.0.0.1"
		mh.vm.network :private_network, ip: "192.168.10.12"
		mh.hostmanager.aliases = %w(mailhog.pterodactyl.local)

		mh.vm.provider "docker" do |d|
			d.image = "mailhog/mailhog"
			d.ports = ["1025:1025", "8025:8025"]
			d.remains_running = true
		end
	end
end