#!/usr/bin/env bash
#
# Starts a cluster of containers and installs InsightEdge there.
#

VER=1.1.0-SNAPSHOT

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters."
    echo "Usage: run.sh <dir with InsightEdge zip> <distribution edition>"
    exit 1
fi

LOCAL_DOWNLOAD_DIR=$1
EDITION=$2

# Stop if anything is running
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/stop.sh

# Run cluster containers
docker run --name master -P -d -v $LOCAL_DOWNLOAD_DIR:/download insightedge-tests-cluster-install:$VER
docker run --name slave1 -P -d -v $LOCAL_DOWNLOAD_DIR:/download insightedge-tests-cluster-install:$VER
docker run --name slave2 -P -d -v $LOCAL_DOWNLOAD_DIR:/download insightedge-tests-cluster-install:$VER
docker run --name client -P -d --link master:master --link slave1:slave1 --link slave2:slave2 -v $LOCAL_DOWNLOAD_DIR:/download insightedge-tests-cluster-install:$VER

# Give permissions to ie-user for mounted folder, and keep write permissions for the group (basically, for host)
docker exec master bash -c 'chown -R ie-user /download & chmod -R g+rw /download'
docker exec slave1 bash -c 'chown -R ie-user /download & chmod -R g+rw /download'
docker exec slave2 bash -c 'chown -R ie-user /download & chmod -R g+rw /download'
docker exec client bash -c 'chown -R ie-user /download & chmod -R g+rw /download'

MASTER_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' master)
SLAVE1_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' slave1)
SLAVE2_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' slave2)
CLIENT_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' client)

echo "Master IP: $MASTER_IP"
echo "Slave1 IP: $SLAVE1_IP"
echo "Slave2 IP: $SLAVE2_IP"
echo "Client IP: $CLIENT_IP"
echo "Local download dir: $LOCAL_DOWNLOAD_DIR"

# Install & smoke test
docker exec --user ie-user client /home/ie-user/remote_install.sh $EDITION


