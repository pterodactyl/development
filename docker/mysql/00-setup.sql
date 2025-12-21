create database if not exists pterodactyl_test;

grant all on pterodactyl_test.* TO 'pterodactyl'@'%';
grant all on `pterodactyl\_test\_test_%`.* TO 'pterodactyl'@'%';

flush privileges;