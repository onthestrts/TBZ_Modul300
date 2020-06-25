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
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: wordpress:5.4.2-php7.3-apache
    ports:
      - "8000:80"
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
    working_dir: /var/www/html
    volumes:
      - ./wp-content:/var/www/html/wp-content
      - ./uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
volumes:
  db_data:
EOT

cat <<EOT >> /home/vagrant/docker/lb3/docker-compose.yml
file_uploads = On
memory_limit = 64M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 600
EOT

