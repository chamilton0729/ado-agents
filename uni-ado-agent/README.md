# Install Azure DevOps (ADO) Universal Agent
_Note: These steps assume the use of an OpenShift Cluster to build and deploy the ADO Universal Agent_

1. Obtain an ADO Personal Access Token from your ADO account
2. Clone this [Repo](https://github.com/chamilton0729/ado-agents)
``` git clone https://github.com/chamilton0729/ado-agents cd ./ado-agents/uni-ado-agent ```
3. Login to OpenShift Cluster
`oc login -u <username> <OpenShift Cluster URL>`
4. Create an OpenShift Project for the ADO Agents
`oc new-project <env>-ado-agents`
5. Import the Red Hat Container Catalog Service Secret
_NOTE:  This is using a Service Account acquired from Red Hat Container Catalog and the secret yaml downloaded prior to running this step_
`oc create -f rh-registry-svc-secret.yaml`
6. Link the Red Hat Container Catalog Service Secret to the Default Service Account
`oc secret link sa/default secret/rh-registry-svc-secret --for=pull`
7. 
`oc secret link sa/builder secret/rh-registry-svc-secret`
8. oc create secret generic uni-ado-agent-access-token --from-literal=ACCESS_TOKEN=<Paste your PAT from Step 1>
    e.g. ajxq6ka...
9. oc create sa uni-ado-agent
10. oc new-build <URL to GIT> --context-dir=uni-azure-ocp-agent --strategy=docker --name=uni-ado-agent
11. oc start-build uni-ado-agent --from-dir=. --follow
12. oc new-app uni-ado-agent -e SERVER_URL=<ADO Org URL> -e AGENT_POOL=<ADO Pool Name>
13. oc set env dc/uni-ado-agent --from=secret/uni-ado-agent-access-token
14. oc patch dc uni-ado-agent -p \
    '{"spec":{"template":{"spec":{"containers":[{"name":"uni-ado-agent","env":
    [{"name":"AGENT_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],
    "lifecycle":{"preStop":{"exec":{"command":["/bin/sh","-c","./config.sh remove --unattended --token $ACCESS_TOKEN"]}}}}],
    "serviceAccountName":"uni-ado-agent"}}}}'
