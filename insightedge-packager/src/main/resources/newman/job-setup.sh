#!/bin/bash
set -x
echo "starting job setup"
JOB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Job DIR: ${JOB_DIR}"
if [ "${DIST_EDITION}" = "community" ]
then
    jar xf resources/gigaspaces-insightedge*community*.zip
    mv gigaspaces-insightedge* build
    mv resources/gigaspaces-insightedge*community*.zip build/
else
    jar xf resources/gigaspaces-insightedge*premium*.zip
    mv gigaspaces-insightedge* build
    mv resources/gigaspaces-insightedge*premium*.zip build/
fi
jar xf resources/integration-tests-sources.zip
mvn -f ${JOB_DIR}/insightedge-integration-tests/pom.xml -P run-integration-tests-${DIST_EDITION} -P setup-external -Ddist.dir=${JOB_DIR}/build clean pre-integration-test
EXIT_CODE=$?
echo "done job setup"
exit $EXIT_CODE
