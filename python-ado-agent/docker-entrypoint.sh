#!/bin/bash
echo "[ENTRYPOINT] Azure DevOps Agent on RHEL for python 3.6]"

if [ -z "$SERVER_URL" -a -z "$ACCESS_TOKEN" -a -z "$AGENT_POOL" -a -z "$AGENT_NAME" ]; then
        echo "[ENTRYPOINT] SERVER_URL, ACCESS_TOKEN, AGENT_POOL, AGENT_NAME have to be populated with correct values."
        exit 1
fi

export GIT_VERSION=$(/opt/rh/rh-git218/root/usr/bin/git --version | awk '{ print $3 }')

if ! ./config.sh --unattended --url $SERVER_URL --auth pat --token $ACCESS_TOKEN --pool $AGENT_POOL --agent $AGENT_NAME --acceptTeeEula ; then
    ./config.sh --unattended --url $SERVER_URL --auth pat --token $ACCESS_TOKEN --pool $AGENT_POOL --agent $AGENT_NAME --replace --acceptTeeEula
fi

scl enable rh-git218 -- bash -c ./run.sh