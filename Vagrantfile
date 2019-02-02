["vagrant-vbguest", "vagrant-hostmanager"].each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      raise plugin + " plugin is not installed. Hint: vagrant plugin install " + plugin
    end
end

vagrant_root = File.dirname(__FILE__)

Vagrant.configure("2") do |config|
	config.hostmanager.enabled = true
	config.hostmanager.manage_host = true
	config.hostmanager.manage_guest = false
	config.hostmanager.ignore_private_ip = false
	config.hostmanager.include_offline = true

	config.vm.define "app", primary: true do |app|
		app.vm.hostname = "app"

		app.vm.synced_folder ".", "/vagrant", disabled: true

		app.hostmanager.aliases = %w(pterodactyl.test)

		app.vm.network "forwarded_port", guest: 80, host: 80
		app.vm.network "forwarded_port", guest: 8080, host: 8080
		app.vm.network "forwarded_port", guest: 8081, host: 8081

		app.ssh.insert_key = true
		app.ssh.username = "root"
		app.ssh.password = "vagrant"

		app.vm.provider "docker" do |d|
			d.image = "quay.io/pterodactyl/vagrant-panel"
			d.create_args = ["-it", "--add-host=host.pterodactyl.test:172.17.0.1"]
			d.ports = ["80:80", "8080:8080", "8081:8081"]

			if ENV['FILE_SYNC_METHOD'] === 'docker-sync'
				d.volumes = ["panel-sync:/srv/www:nocopy"]
			else
				d.volumes = ["#{vagrant_root}/code/panel:/srv/www:cached"]
			end

			d.remains_running = true
			d.has_ssh = true
		end

		app.vm.provision "deploy_files", type: "file", source: "#{vagrant_root}/build/configs", destination: "/tmp/.deploy"
		app.vm.provision "configure_application", type: "shell", path: "#{vagrant_root}/scripts/deploy_app.sh"
		app.vm.provision "setup", type: "shell", run: "never", inline: <<-SHELL
			cd /srv/www

			cp .env .env.bkup
			php artisan key:generate --force --no-interaction

			php artisan p:environment:setup --new-salt --author="you@example.com" --url="http://pterodactyl.test" --timezone="America/Los_Angeles" --cache=redis --session=redis --queue=redis --redis-host="host.pterodactyl.test" --no-interaction
			php artisan p:environment:database --host="host.pterodactyl.test" --database=panel --username=pterodactyl --password=pterodactyl --no-interaction
			php artisan p:environment:mail --driver=smtp --email="outgoing@example.com" --from="Pterodactyl Panel" --host="host.pterodactyl.test" --port=1025 --no-interaction

			php artisan migrate --seed
		SHELL
	end

	config.vm.define "wings", autostart: false do |wings|
		wings.vm.hostname = "wings"
	
		wings.vm.box = "bento/ubuntu-18.04"

		wings.vm.synced_folder ".", "/vagrant", disabled: true
		wings.vm.synced_folder "#{vagrant_root}/code/wings", "/home/vagrant/go/src/github.com/pterodactyl/wings",
			owner: "vagrant", group: "vagrant"

		wings.vm.network :forwarded_port, guest: 8080, host: 58080
		wings.hostmanager.aliases = %w(wings.test)

		wings.vm.provision "provision", type: "shell", path: "#{vagrant_root}/scripts/provision_wings.sh"
	end

	config.vm.define "daemon", autostart: false do |daemon|
		daemon.vm.hostname = "daemon.pterodactyl.test"
		daemon.vm.box = "bento/ubuntu-18.04"

		daemon.vm.synced_folder ".", "/vagrant", disabled: true
		daemon.vm.synced_folder "#{vagrant_root}/code/daemon", "/srv/daemon", owner: "vagrant", group: "vagrant"
		daemon.vm.synced_folder "#{vagrant_root}/code/sftp-server", "/home/vagrant/go/src/github.com/pterodactyl/sftp-server", owner: "vagrant", group: "vagrant"
		daemon.vm.synced_folder ".data/daemon-data", "/srv/daemon-data", create: true

		daemon.vm.network :private_network, ip: "192.168.50.4"
		daemon.vm.network :forwarded_port, guest: 8080, host: 58081
		daemon.vm.network :forwarded_port, guest: 8022, host: 58022

		daemon.vm.provision "provision", type: "shell", path: "#{vagrant_root}/scripts/provision_daemon.sh"
	end

	config.vm.define "docs" do |docs|
		docs.vm.hostname = "documentation"
		docs.vm.synced_folder ".", "/vagrant", disabled: true

		docs.hostmanager.aliases = %w(pterodocs.test)
		docs.vm.network "forwarded_port", guest: 80, host: 9090
		docs.vm.network "forwarded_port", guest: 9091, host: 9091

		docs.ssh.insert_key = true
		docs.ssh.username = "root"
		docs.ssh.password = "vagrant"

		docs.vm.provider "docker" do |d|
			d.image = "quay.io/pterodactyl/vagrant-core"
			d.create_args = ["-it", "--add-host=host.pterodactyl.test:172.17.0.1"]
			d.ports = ["9090:80", "9091:9091"]
			d.volumes = ["#{vagrant_root}/code/documentation:/srv/documentation:cached"]
			d.remains_running = true
			d.has_ssh = true
			d.privileged = true
		end

		docs.vm.provision "deploy_files", type: "file", source: "#{vagrant_root}/build/configs", destination: "/tmp/.deploy"
		docs.vm.provision "setup_documentation", type: "shell", path: "#{vagrant_root}/scripts/deploy_docs.sh"
	end


	# Configure a mysql docker container.
	config.vm.define "mysql" do |mysql|
		mysql.vm.hostname = "mysql"
		mysql.vm.synced_folder ".", "/vagrant", disabled: true
		mysql.vm.synced_folder ".data/mysql", "/var/lib/mysql", create: true

		mysql.vm.network "forwarded_port", guest: 3306, host: 3306
		mysql.hostmanager.aliases = %w(mysql.pterodactyl.test)

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

	config.vm.define "chromedriver" do |chrome|
		chrome.vm.hostname = "chromedriver"
		chrome.vm.synced_folder ".", "/vagrant", disabled: true

		chrome.vm.network "forwarded_port", guest: 4444, host: 4444
		chrome.vm.network "forwarded_port", guest: 5900, host: 5900
		chrome.hostmanager.aliases = %w(chrome.pterodactyl.test)

		chrome.vm.provider "docker" do |d|
			d.image = "selenium/standalone-chrome-debug:3.12.0-boron"
			d.ports = ["5900:5900", "4444:4444"]
			d.create_args = ["--add-host=pterodactyl.test:172.17.0.1"]
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
		mh.hostmanager.aliases = %w(mailhog.pterodactyl.test)

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
		redis.hostmanager.aliases = %w(redis.pterodactyl.test)

		redis.vm.provision :hostmanager

		redis.vm.provider "docker" do |d|
			d.image = "redis:4.0-alpine"
			d.ports = ["6379:6379"]
			d.remains_running = true
		end
	end
end
