#!/bin/bash -x
set -e
printenv

host=${storageHost}
echo "host=${host}"

port=${storagePort}
echo "port=${port}"

user=${storageUser}
echo "user=${user}"

if [ -n "$GIT_BRANCH" ]; then
    branch=${GIT_BRANCH#*/}
else
    branch=${branch="master"}
fi
echo "branch=${branch}"

version=${buildVersion}
echo "version=${version}"

buildNumber=${buildNumber}
echo "buildNumber=${buildNumber}"

build_path="${version}/${branch}/${buildNumber}"
path_on_server="/home/giga/backup-store/insightedge/$build_path"

communityZipFilePath=${baseOutputFolder}/community/${communityZipFileName}
premiumZipFilePath=${baseOutputFolder}/premium/${premiumZipFileName}

echo "check if insightedge community zip exists"
ls -l ${communityZipFilePath}

echo "check if insightedge premium zip exists"
ls -l ${premiumZipFilePath}

echo "creating dir in server - [$path_on_server]"
ssh ${user}@${host} mkdir -p ${path_on_server}
ssh ${user}@${host} chown -R "${user}:domain\ users" ${path_on_server}

echo "coping resources to: [$host] to folder in server:[${path_on_server}]"
scp ${communityZipFilePath} ${premiumZipFilePath} ${baseOutputFolder}/*.json ${baseOutputFolder}/integration-tests-sources.zip ${baseOutputFolder}/metadata.txt ${baseOutputFolder}/newman-artifacts.zip ${user}@${host}:${path_on_server}
ssh ${user}@${host} chmod -R 755 ${path_on_server}

echo "starting newman submitter process..."
java -version
sumbitter_jar=${baseOutputFolder}/newman-submitter-1.0.jar
if [ -f $sumbitter_jar ]; then
    BASE_WEB_URI=http://${host}:${port}/insightedge
    WEB_PATH_TO_BUILD=${BASE_WEB_URI}/${build_path}
    echo "web url for build resources: ${WEB_PATH_TO_BUILD}"

    export NEWMAN_HOST=${newmanHost="xap-newman"}
    export NEWMAN_PORT=${newmanPort="8443"}
    export NEWMAN_USER_NAME=${newmanUsername="root"}
    export NEWMAN_PASSWORD=${newmanPassword="root"}

    export NEWMAN_BUILD_BRANCH=${branch}
    export NEWMAN_BUILD_NUMBER=${buildNumber}
    export NEWMAN_BUILD_TAGS=${newmanTags}
    export NEWMAN_BUILD_TESTS_METADATA=${WEB_PATH_TO_BUILD}/ie-integration-tests.json
    export NEWMAN_BUILD_SHAS_FILE=${WEB_PATH_TO_BUILD}/metadata.txt
    export NEWMAN_BUILD_RESOURCES=${WEB_PATH_TO_BUILD}/integration-tests-sources.zip,${WEB_PATH_TO_BUILD}/${communityZipFileName},${WEB_PATH_TO_BUILD}/${premiumZipFileName},${WEB_PATH_TO_BUILD}/newman-artifacts.zip

    echo "NEWMAN_BUILD_BRANCH=${NEWMAN_BUILD_BRANCH}"
    echo "NEWMAN_BUILD_NUMBER=${NEWMAN_BUILD_NUMBER}"
    echo "NEWMAN_HOST=${NEWMAN_HOST}"
    echo "NEWMAN_USER_NAME=${NEWMAN_USER_NAME}"
    echo "NEWMAN_BUILD_TESTS_METADATA=${NEWMAN_BUILD_TESTS_METADATA}"
    echo "NEWMAN_BUILD_SHAS_FILE=${NEWMAN_BUILD_SHAS_FILE}"
    echo "NEWMAN_BUILD_RESOURCES=${NEWMAN_BUILD_RESOURCES}"
    java -cp ${sumbitter_jar} com.gigaspaces.newman.NewmanBuildSubmitter
    echo "finished newman submitter process successfully"
else
    echo "skipping newman submitter process because the file ${sumbitter_jar} does not exists"
    exit 1
fi