# Install Azure DevOps (ADO) Universal Agent
_Note: These steps assume the use of an OpenShift Cluster to build and deploy the ADO Universal Agent_

1. Obtain an ADO Personal Access Token from your ADO account
2. Clone this [Repo](https://github.com/chamilton0729/ado-agents)
```
  git clone https://github.com/chamilton0729/ado-agents
  cd ./ado-agents/uni-ado-agent
```
3. Login to OpenShift Cluster
```
  oc login -u <username> <OpenShift Cluster URL>
```
4. Create an OpenShift Project for the ADO Agents
```
  oc new-project <env>-ado-agents
```
5. Import the Red Hat Container Catalog Service Secret
* _Note:  This is using a Service Account acquired from Red Hat Container Catalog and the secret yaml downloaded prior to running this step_
```
  oc create -f rh-registry-svc-secret.yaml
```
6. Link the Red Hat Container Catalog Service Secret to the Default Service Account
```
  oc secret link sa/default secret/rh-registry-svc-secret --for=pull
```
7. Link the Red Hat Container Catalog Service Secret to the Default Builder Account 
```
  oc secret link sa/builder secret/rh-registry-svc-secret
```
8. Create the Secret for the ADO PAT 
```
  oc create secret generic uni-ado-agent-access-token --from-literal=ACCESS_TOKEN=<PAT from Step 1>
  e.g. ajxq6ka...
```
9. Create the Universal ADO Agent Service account used to run the agents
```
  oc create sa uni-ado-agent
```
10. Create the Build Configuration of the Universal ADO Agent Docker Image
```
  oc new-build <URL to GIT> --context-dir=uni-azure-ocp-agent --strategy=docker --name=uni-ado-agent
```
11. Start the Build of the Universal ADO Agent Docker Image
```
  oc start-build uni-ado-agent --from-dir=. --follow
```
12. Create and Start the Deployment of the Universal ADO Agent using the ADO Org URL and Agent Pool Name
```
  oc new-app uni-ado-agent -e SERVER_URL=<ADO Org URL> -e AGENT_POOL=<ADO Pool Name>
```
13. Update the Deployment to use the ADO PAT as an Environment variable
```
  oc set env dc/uni-ado-agent --from=secret/uni-ado-agent-access-token
```
14. Patch the Deployment to define the AGENT_NAME and create a Lifecycle hook to cleanup stale agents
```
  oc patch dc uni-ado-agent -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"uni-ado-agent","env":
  [{"name":"AGENT_NAME","valueFrom":{"fieldRef":{"fieldPath":"metadata.name"}}}],
  "lifecycle":{"preStop":{"exec":{"command":["/bin/sh","-c","./config.sh remove --unattended --token $ACCESS_TOKEN"]}}}}],
  "serviceAccountName":"uni-ado-agent"}}}}'
```

