#!/bin/bash
set -e

# Use a local directory for testing to avoid dependency on /mnt/ssd_sandisk
TEST_DIR="$(pwd)/test_data"
mkdir -p "$TEST_DIR"

echo "Running verification test for dev_env..."

# 1. Create necessary directories
echo "Creating directories in $TEST_DIR..."
mkdir -p "$TEST_DIR"/{postgres_data,geoserver_data,geoserver_config,geonetwork_data,redis_data,mongodb_data}

# 2. Extract web.xml (simulating setup-geoserver-cors.sh logic)
GEOSERVER_IMAGE="docker.osgeo.org/geoserver:2.28.0"
echo "Extracting web.xml from $GEOSERVER_IMAGE..."
# Using docker export to avoid running the full container
CONTAINER_ID=$(docker create "$GEOSERVER_IMAGE")
docker export "$CONTAINER_ID" | tar -Ox usr/local/tomcat/webapps/geoserver/WEB-INF/web.xml > "$TEST_DIR/geoserver_config/web-official.xml"
docker rm "$CONTAINER_ID"

# 3. Create a dummy nginx.conf (since it's referenced in docker-compose.yml)
cat <<EOF > "$TEST_DIR/geoserver_config/nginx.conf"
events {}
http {
    server {
        listen 8090;
        location / {
            proxy_pass http://geoserver:8080;
        }
    }
}
EOF

# 4. Create a temporary docker-compose.test.yml with adjusted paths
sed "s|/mnt/ssd_sandisk|$TEST_DIR|g" docker-compose.yml > docker-compose.test.yml

# 5. Start the stack (only postgres and redis for quick test)
echo "Starting Postgres and Redis services..."
docker-compose -f docker-compose.test.yml up -d postgres redis

# 6. Wait for services to be ready
echo "Waiting for services..."
sleep 5

# 7. Check if containers are running
if [ "$(docker inspect -f '{{.State.Running}}' postgres)" == "true" ] && [ "$(docker inspect -f '{{.State.Running}}' redis)" == "true" ]; then
    echo "✅ Postgres and Redis are running successfully."
else
    echo "❌ Failed to start services."
    docker-compose -f docker-compose.test.yml logs
    exit 1
fi

# 8. Cleanup
echo "Cleaning up..."
docker-compose -f docker-compose.test.yml down
rm docker-compose.test.yml
rm -rf "$TEST_DIR"

echo "Test passed!"
