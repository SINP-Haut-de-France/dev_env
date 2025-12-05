# dev_env
Environnement docker complet proposant geonetwork, geoserver, postges + postgis, redis et mongodb


Commandes à exécuter (création des dossiers + permissions recommandées)

Exécuter ces commandes sur l'hôte, l'exemple ici montre l'utilisation d'un répertoire externe pour rendre disponible les répertoires de configuration et de données des différentes applications:

Le répertoire /mnt/ssd_sandisk/ peut être modifié à votre convenance. 

NOTE : le docker-compose utilise le répertoire /mnt/san_disk/ mais il doit être modifié en fonction du répertoire que vous souahitez utiliser. Il en va de même pour les ports hôtes utilisés, dans mon cas j'utilise le port standard de postgres et les ports 8080 et 8081 pour geoserver et geonetwork.

# 1) créer les dossiers
sudo mkdir -p /mnt/ssd_sandisk/{postgres_data,geoserver_data,geoserver_webapps,geonetwork_data,redis_data,mongodb_data}

# 2) appliquer permissions raisonnables
# GeoServer & GeoNetwork : processus dans les conteneurs utilisent UID 1000 (ubuntu)
sudo chown -R 1000:1000 /mnt/ssd_sandisk/geoserver_data /mnt/ssd_sandisk/geoserver_webapps /mnt/ssd_sandisk/geonetwork_data

# Redis & MongoDB : on applique des permissions larges mais sécurisées (groupe root)
sudo chmod -R 770 /mnt/ssd_sandisk/redis_data /mnt/ssd_sandisk/mongodb_data

# (optionnel) si l'on souhaite que les données Mongo/Redis appartiennent à un utilisateur particulier
# -> il suffit d'ajuster le UID après avoir démarré et inspecté les UIDs des processus dans les conteneurs

3) Démarrage de la stack
cd $HOME$/repository/dev_env
sudo docker-compose down --remove-orphans
sudo docker-compose up -d --force-recreate

4) Vérifications & dépannage rapide en cas d'erreur de permission

Après up -d :

# vérifier que les containers sont up
sudo docker ps --filter "name=geoserver" --filter "name=postgres" --filter "name=geonetwork" --filter "name=redis" --filter "name=mongodb" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# inspect mounts
sudo docker inspect redis --format '{{json .Mounts}}' | jq .
sudo docker inspect mongodb --format '{{json .Mounts}}' | jq .

# logs si pb
sudo docker logs redis --tail 100
sudo docker logs mongodb --tail 100


Si un conteneur indique permission denied ou n’arrive pas à écrire :

Inspecter l'UID du processus dans le conteneur (pour savoir quel UID doit posséder les fichiers) :

# pour Redis
sudo docker exec -it redis id -u -n || sudo docker exec -it redis id

# pour Mongo
sudo docker exec -it mongodb id -u -n || sudo docker exec -it mongodb id


Si l'UID retourné est (par exemple) 999 ou 1001, on applique sur l'hôte :

# remplacer 999 par l'UID correct trouvé
sudo chown -R 999:999 /mnt/ssd_sandisk/mongodb_data
# et pour redis si nécessaire
sudo chown -R 999:999 /mnt/ssd_sandisk/redis_data


Redémarrer uniquement les services concernés :

sudo docker-compose restart mongodb
sudo docker-compose restart redis


