# 🚀 Guide d'installation - Environnement de développement GeoData

## Installation complète sur un nouveau PC/disque

### Prérequis
- Docker et docker-compose installés
- Un disque de stockage disponible (par défaut `/mnt/ssd_sandisk/`)
- Git installé

---

## 📦 Installation en 3 étapes

### 1️⃣ Cloner le repository

```bash
git clone https://github.com/SINP-Haut-de-France/dev_env.git
cd dev_env
```

### 2️⃣ Exécuter le script d'initialisation

```bash
./setup-geoserver-cors.sh
```

Ce script va automatiquement :
- ✅ Créer tous les répertoires nécessaires
- ✅ Télécharger l'image GeoServer officielle
- ✅ Extraire et configurer le fichier `web.xml` avec CORS activé
- ✅ Ajuster les permissions

### 3️⃣ Démarrer les services

```bash
sudo docker-compose up -d
```

**C'est tout !** 🎉

---

## 🔄 Réinstallation sur un nouveau PC

Si vous déplacez l'environnement sur un nouveau PC ou disque dur :

### Option A : Avec le script (recommandé)

```bash
cd dev_env
./setup-geoserver-cors.sh
sudo docker-compose up -d
```

### Option B : Manuellement

```bash
# 1. Créer les répertoires
sudo mkdir -p /mnt/ssd_sandisk/{postgres_data,geoserver_data,geoserver_config,geonetwork_data,redis_data,mongodb_data}

# 2. Extraire le web.xml depuis l'image GeoServer
docker pull docker.osgeo.org/geoserver:2.28.0
docker run --rm docker.osgeo.org/geoserver:2.28.0 \
  cat /usr/local/tomcat/webapps/geoserver/WEB-INF/web.xml > /tmp/geoserver-web.xml

# 3. Activer CORS en décommentant les sections Tomcat
sed '/Uncomment following filter to enable CORS in Tomcat/,/-->/{s/<!--//g; s/-->//g}' \
  /tmp/geoserver-web.xml | \
sed '/Uncomment following filter-mapping to enable CORS/,/-->/{s/<!--//g; s/-->//g}' \
  > /mnt/ssd_sandisk/geoserver_config/web-official.xml

# 4. Ajuster les permissions
sudo chown -R $USER:$USER /mnt/ssd_sandisk/geoserver_config

# 5. Démarrer
sudo docker-compose up -d
```

---

## 📁 Structure des données

```
/mnt/ssd_sandisk/
├── postgres_data/          # Données PostgreSQL/PostGIS (auto-créé par container)
├── geoserver_data/         # Données GeoServer (layers, styles, workspaces)
├── geoserver_config/       # Configuration GeoServer
│   └── web-official.xml    # ⚠️ Fichier requis avec CORS activé
├── geonetwork_data/        # Données GeoNetwork (métadonnées, ressources)
├── redis_data/             # Données Redis (auto-créé par container)
└── mongodb_data/           # Données MongoDB (auto-créé par container)
```

### ⚠️ Fichiers critiques à préserver

Le seul fichier **obligatoire** à créer avant le démarrage est :
- `/mnt/ssd_sandisk/geoserver_config/web-official.xml`

Tous les autres répertoires sont créés automatiquement par les containers.

---

## 🌐 Services disponibles après démarrage

| Service | Port | URL | Identifiants |
|---------|------|-----|--------------|
| **PostgreSQL/PostGIS** | 5433 | `localhost:5433` | user: `ducrocqm` / pass: `admin_666` |
| **GeoServer** | 8080 | http://localhost:8080/geoserver | admin / geoserver |
| **GeoNetwork** | 8081 | http://localhost:8081/geonetwork | admin / admin |
| **Redis** | 6379 | `localhost:6379` | - |
| **MongoDB** | 27017 | `localhost:27017` | user: `mongo_admin` / pass: `admin_666` |

---

## ✅ Vérifications post-installation

### 1. Vérifier que les containers sont démarrés

```bash
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Vous devriez voir 5 containers actifs : `postgres`, `geoserver`, `geonetwork`, `redis`, `mongodb`

### 2. Tester CORS de GeoServer

```bash
curl -I -X OPTIONS http://localhost:8080/geoserver/wfs \
  -H "Origin: http://localhost:5051" \
  -H "Access-Control-Request-Method: GET"
```

Vous devriez voir : `Access-Control-Allow-Origin: *`

### 3. Tester l'accès aux services

```bash
# PostgreSQL
psql -h localhost -p 5433 -U ducrocqm -d sinp

# GeoServer
curl http://localhost:8080/geoserver/web/

# GeoNetwork
curl http://localhost:8081/geonetwork/
```

---

## 🔧 Personnalisation

### Changer le chemin de stockage

Si vous voulez utiliser un autre disque que `/mnt/ssd_sandisk/` :

1. **Éditez `setup-geoserver-cors.sh`** :
   ```bash
   SSD_PATH="/votre/nouveau/chemin"
   ```

2. **Éditez `docker-compose.yml`** :
   Remplacez tous les `/mnt/ssd_sandisk/` par votre nouveau chemin

3. **Relancez le script et docker-compose**

### Changer les ports

Éditez `docker-compose.yml` et modifiez les ports dans la section `ports:` de chaque service.

---

## ❓ Dépannage

### Container GeoServer ne démarre pas

```bash
# Vérifier les logs
sudo docker logs geoserver --tail 100

# Vérifier que le fichier web.xml existe
ls -la /mnt/ssd_sandisk/geoserver_config/web-official.xml

# Recréer le fichier CORS
./setup-geoserver-cors.sh
sudo docker-compose restart geoserver
```

### Problème de permissions

```bash
# Vérifier les propriétaires
ls -la /mnt/ssd_sandisk/

# Ajuster si nécessaire
sudo chown -R $USER:$USER /mnt/ssd_sandisk/geoserver_config
sudo chown -R $USER:$USER /mnt/ssd_sandisk/geonetwork_data
```

### CORS ne fonctionne pas

```bash
# Vérifier que le filtre CORS est bien actif dans web.xml
grep -A 5 "cross-origin" /mnt/ssd_sandisk/geoserver_config/web-official.xml

# Si les lignes sont encore commentées (<!--), refaire le script
./setup-geoserver-cors.sh
sudo docker-compose restart geoserver
```

---

## 📚 Documentation complète

Pour plus d'informations, consultez :
- [Docker Compose reference](https://docs.docker.com/compose/)
- [GeoServer documentation](https://docs.geoserver.org/)
- [GeoNetwork documentation](https://geonetwork-opensource.org/manuals/trunk/en/index.html)
