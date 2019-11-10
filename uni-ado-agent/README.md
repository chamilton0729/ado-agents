#Install Azure DevOps (ADO) Universal Agent

1.  Obtain an ADO Personal Access Token from your ADO account
2.  Clone this Repo
3.  cd ./ado-agents/uni-ado-agent
4.  oc login -u <username> <OpenShift Cluster URL>
5.  oc new-project <env>-ado-agents
6.  oc create -f rh-registry-svc-secret.yaml

NOTE:  This is using a Service Account acquired from Red Hat Container Catalog and the secret yaml downloaded prior to running this step
7.  oc secret link sa/default secret/rh-registry-svc-secret --for=pull
8.  oc secret link sa/builder secret/rh-registry-svc-secret
9.  oc create secret generic uni-ado-agent-access-token --from-literal=ACCESS_TOKEN=<Paste your PAT from Step 1>
    e.g. ajxq6ka...
10. oc create sa uni-ado-agent
11. oc new-build <URL to GIT> --context-dir=uni-azure-ocp-agent --strategy=docker --name=uni-ado-agent
12. oc start-build uni-ado-agent --from-dir=. --follow
13. oc new-app uni-ado-agent -e SERVER_URL=<ADO Org URL> -e AGENT_POOL=<ADO Pool Name>
14. oc set env dc/uni-ado-agent --from=secret/uni-ado-agent-access-token
15. oc patch dc uni-ado-agent -p \
    '{"spec":{"template":{"spec":{"containers":[{"name":"uni-ado-agent","env":
    [{"name":"AGENT_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],
    "lifecycle":{"preStop":{"exec":{"command":["/bin/sh","-c","./config.sh remove --unattended --token $ACCESS_TOKEN"]}}}}],
    "serviceAccountName":"uni-ado-agent"}}}}'
