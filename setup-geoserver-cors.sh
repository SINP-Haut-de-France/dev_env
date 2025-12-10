#!/bin/bash
#
# Script d'initialisation de l'environnement GeoServer avec CORS
# À exécuter AVANT le premier docker-compose up
#

set -e

echo "🚀 Initialisation de l'environnement GeoServer..."

# Variables
SSD_PATH="/mnt/ssd_sandisk"
CONFIG_DIR="${SSD_PATH}/geoserver_config"
GEOSERVER_IMAGE="docker.osgeo.org/geoserver:2.28.0"

# 1. Vérifier que le disque est monté
if [ ! -d "$SSD_PATH" ]; then
    echo "❌ Erreur: Le disque $SSD_PATH n'est pas monté"
    exit 1
fi

echo "✅ Disque SSD détecté"

# 2. Créer les répertoires
echo "📁 Création des répertoires..."
sudo mkdir -p "${SSD_PATH}/postgres_data"
sudo mkdir -p "${SSD_PATH}/geoserver_data"
sudo mkdir -p "${SSD_PATH}/geoserver_config"
sudo mkdir -p "${SSD_PATH}/geonetwork_data"
sudo mkdir -p "${SSD_PATH}/redis_data"
sudo mkdir -p "${SSD_PATH}/mongodb_data"

echo "✅ Répertoires créés"

# 3. Télécharger l'image GeoServer si nécessaire
echo "📦 Vérification de l'image GeoServer..."
if ! docker image inspect "$GEOSERVER_IMAGE" &> /dev/null; then
    echo "⬇️  Téléchargement de l'image GeoServer..."
    docker pull "$GEOSERVER_IMAGE"
else
    echo "✅ Image GeoServer déjà présente"
fi

# 4. Extraire et configurer le web.xml avec CORS
echo "⚙️  Configuration CORS..."

# Extraire le web.xml original
docker run --rm "$GEOSERVER_IMAGE" cat /usr/local/tomcat/webapps/geoserver/WEB-INF/web.xml > /tmp/geoserver-web.xml

# Décommenter les sections CORS pour Tomcat
sed '/Uncomment following filter to enable CORS in Tomcat/,/-->/{
  s/<!--//g
  s/-->//g
}' /tmp/geoserver-web.xml | \
sed '/Uncomment following filter-mapping to enable CORS/,/-->/{
  s/<!--//g
  s/-->//g
}' > "${CONFIG_DIR}/web-official.xml"

# Ajuster les permissions
sudo chown -R $USER:$USER "${CONFIG_DIR}"

echo "✅ Configuration CORS créée: ${CONFIG_DIR}/web-official.xml"

# 5. Vérifier que CORS est bien décommenté
if grep -q '<filter-name>cross-origin</filter-name>' "${CONFIG_DIR}/web-official.xml" | grep -v '<!--'; then
    echo "✅ CORS activé dans le web.xml"
else
    echo "⚠️  Attention: CORS pourrait ne pas être correctement activé"
fi

# 6. Nettoyage
rm -f /tmp/geoserver-web.xml

echo ""
echo "✅ Initialisation terminée avec succès!"
echo ""
echo "Vous pouvez maintenant lancer:"
echo "  sudo docker-compose up -d"
echo ""
