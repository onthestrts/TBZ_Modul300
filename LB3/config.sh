# Modul 300 - TBZ
# Flurin Kärcher
# Date: 06.07.2020

apt-get update
apt-get install -y docker.io
apt-get install -y docker-compose
service docker start

mkdir /home/vagrant/docker
mkdir /home/vagrant/docker/lb3
touch /home/vagrant/docker/lb3/docker-compose.yml
touch /home/vagrant/docker/lb3/uploads.ini

cat <<EOT >> /home/vagrant/docker/lb3/docker-compose.yml
version: '2'

services:
   db:
     image: mysql:5.7
     volumes:
       - db_data:/var/lib/mysql
     restart: always
     environment:
       MYSQL_ROOT_PASSWORD: lb3-m300
       MYSQL_DATABASE: wordpress
       MYSQL_USER: wordpress
       MYSQL_PASSWORD: lb3-m300

   wordpress:
     depends_on:
       - db
     image: wordpress:latest
     ports:
       - "8000:80"
     restart: always
     environment:
       WORDPRESS_DB_HOST: db:3306
       WORDPRESS_DB_USER: wordpress
       WORDPRESS_DB_PASSWORD: lb3-m300
       WORDPRESS_DB_NAME: wordpress
volumes:
    db_data: {}
EOT
docker-compose /home/vagrant/docker/lb3/docker-compose.yml up -d

