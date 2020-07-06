# LB3 - WordPress automatisch aufbauen
Wir haben über Vagrant eine vollautomatischer Aufbau einer VM mit einer WordPress installation gebaut. Diese WordPress installation wird vollautomatisch in einem Docker Container aufgebaut. Dabei wird eine DB erstellt worin dann die Einstellungen, Benutzer etc. gespeichert werden.
Die Meinung ist, dass man nur das Vagrant script mit

    vagrant up
starten muss.

## Aufbau Vagrant script
Das Script für den Aufbau der VM haben wir noch aus der LB2 genommen, da wir fanden, dass das eine gute Grundlage für die weiteren Arbeiten sein kann:  

    # Modul300 - TBZ
    # Flurin Kärcher
    # Date: 25.06.2020
    
    Vagrant.configure("2") do |config|
    
      config.vm.box = "ubuntu/xenial64"
    
      config.vm.box_check_update = false
    
      # config.vm.network "public_network", ip: "172.17.120.64"
      config.vm.network "public_network"
    
      config.vm.provider "virtualbox" do |vb|
    
         vb.gui = false
    
         vb.memory = "2048"
      end
    
     config.vm.provision "shell", path: "config.sh"
    
    end

Das einzigen was wir in diesem Script geändert haben, ist die grösse des RAMs und es wird kein Apache installiert, da das Docker dann automatisch macht.

## Installation Docker und WordPress
Wie wir bereits weiter oben angetönt haben, war unser Ziel dass alles vollautomatisch installiert und konfiguriert wird. Das geht von der eigentlichen VM (Vagrant) bis zu WordPress mit einer DB im Hintergrund.

Damit die entsprechenden Scripts/Befehle auf der neu gebauten Vagrant Maschine abgesetzt werden, haben wir ein lokales Script gemacht, welches beim Bau der VM ausgeführt wird:

    config.vm.provision "shell", path: "config.sh"
Das config.sh Script muss zwingend im gleichen Pfad wie das Vagrant File sein. Sonst wird das Script nicht geladen und wird auch nichts konfiguriert.
Das config.sh Script sieht dann folgendermassen aus:

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
           MYSQL_ROOT_PASSWORD: ####
           MYSQL_DATABASE: wordpress
           MYSQL_USER: wordpress
           MYSQL_PASSWORD: ###
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
           WORDPRESS_DB_PASSWORD: ###
           WORDPRESS_DB_NAME: wordpress
    volumes:
        db_data: {}
    EOT
    docker-compose /home/vagrant/docker/lb3/docker-compose.yml up -d

### Erklärung des Scripts

**Der Anfang:**
Hier werden zuerst Updates geladen und Docker installiert. Am Ende wird dann der Docker Dienst
noch gestartet. Wenn das nicht gemacht wird, können keine Container gebaut und betrieben werden.

Im nächsten Schritt wird das Directory angelegt in dem dann der Docker Container gebaut und Kompiliert wird. Damit das dann auch funktioniert, werden dann auch noch gleich die nötigen Files erstellt.


    apt-get update
    apt-get install -y docker.io
    apt-get install -y docker-compose
    service docker start
    
    mkdir /home/vagrant/docker
    mkdir /home/vagrant/docker/lb3
    touch /home/vagrant/docker/lb3/docker-compose.yml
    touch /home/vagrant/docker/lb3/uploads.ini
    
    
**Die Mitte:**   
Hier wird eigentlich einfach das Docker File geschrieben. Hier stehen die ganzen Konfigurationen gemacht zur DB und auch gleich zu Wordpress. Wir haben es so eingestellt, dass wir jeweils immer die neuste verfügbaren Versionen von WordPress und MYSQL gezogen werden. Natürlich müssen hier die Passwörter abgeändert werden (überall wo ### steht).

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
**Das Ende:**
Hier im letzten Schritt wird nur noch das .yml File kompiliert und der Container gestartet.

    docker-compose /home/vagrant/docker/lb3/docker-compose.yml up -d


