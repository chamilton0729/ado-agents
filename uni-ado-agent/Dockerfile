FROM registry.redhat.io/openshift3/ose-cli:v3.11.153-2

#Set a Default Azure DevOps Agent Version for Download
ARG AZURE_DEVOPS_AGENT_VERSION=2.155.1

COPY docker-entrypoint.sh /ado-agent/entrypoint.sh

#Run commands with the first checking to get the latest Azure DevOps Agent version if there is a newer one
#E.g. https://vstsagentpackage.azureedge.net/agent/2.150.3/vsts-agent-linux-x64-2.150.3.tar.gz
RUN AZURE_DEVOPS_AGENT_VERSION=$(curl -k https://github.com/Microsoft/azure-pipelines-agent/releases/latest \
	| awk '{print $5}' | awk -F \" '{print $2}' | awk -F /v '{print $2}') \
	&& chmod +x /ado-agent/entrypoint.sh \
	&& wget -nv \
    https://vstsagentpackage.azureedge.net/agent/$AZURE_DEVOPS_AGENT_VERSION/vsts-agent-linux-x64-${AZURE_DEVOPS_AGENT_VERSION}.tar.gz \
    -O /ado-agent/vsts-agent-linux-x64.tar.gz \
	&& wget -nv https://github.com/sclorg/s2i-base-container/blob/7a3edb0261ebba12f250620fd480a52df3fd4e76/core/root/usr/bin/fix-permissions?raw=true \
	-O /usr/bin/fix-permissions && chmod +x /usr/bin/fix-permissions \ 
	&& cd /ado-agent \
	&& tar -zxf vsts-agent-linux-x64.tar.gz \
	&& wget -nv https://get.helm.sh/helm-v3.0.0-beta.3-linux-amd64.tar.gz -O /ado-agent/helm-v3-linux-amd64.tar.gz \
	&& tar -zxf helm-v3-linux-amd64.tar.gz \ 
        && yum-config-manager --enable rhel-server-rhscl-7-rpms \
	&& yum install rh-git218 dos2unix -y \
	&& ./bin/installdependencies.sh \
	&& yum install -y docker-1.13.1 \
	&& yum install -y ant \
	&& yum install -y maven \
	&& yum install -y ruby \
        && yum clean all \
	&& rm /ado-agent/vsts-agent-linux-x64.tar.gz \
	&& rm /ado-agent/helm-v3-linux-amd64.tar.gz \
	&& mkdir -p /.kube \
	&& fix-permissions /.kube -P \
	&& chown -R 1001:0 /ado-agent \
	&& fix-permissions /ado-agent -P

USER 1001

WORKDIR /ado-agent

ENTRYPOINT ["./entrypoint.sh"]
