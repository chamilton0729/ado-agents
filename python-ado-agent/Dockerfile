FROM registry.redhat.io/rhscl/python-36-rhel7:1-41

#Set a Default Azure DevOps Agent Version for Download
ARG AZURE_DEVOPS_AGENT_VERSION=2.155.1

USER root

COPY docker-entrypoint.sh $APP_ROOT/ado-agent/entrypoint.sh

#Run commands with the first checking to get the latest Azure DevOps Agent version if there is a newer one
RUN AZURE_DEVOPS_AGENT_VERSION=$(curl -k https://github.com/Microsoft/azure-pipelines-agent/releases/latest \
	| awk '{print $5}' | awk -F \" '{print $2}' | awk -F /v '{print $2}') \
	&& cd $APP_ROOT \
	&& wget -nv \
    https://vstsagentpackage.azureedge.net/agent/$AZURE_DEVOPS_AGENT_VERSION/vsts-agent-linux-x64-${AZURE_DEVOPS_AGENT_VERSION}.tar.gz \
    -O ado-agent/vsts-agent-linux-x64.tar.gz && cd ado-agent && tar -zxf vsts-agent-linux-x64.tar.gz \
    && chmod +x entrypoint.sh && yum-config-manager --enable rhel-server-rhscl-7-rpms \
    && yum install rh-git218 dos2unix -y && ./bin/installdependencies.sh && yum clean all && rm vsts-agent-linux-x64.tar.gz \
    && chown -R 1001:0 ${APP_ROOT} && fix-permissions ${APP_ROOT} -P

USER 1001

WORKDIR $APP_ROOT/ado-agent

ENTRYPOINT ["./entrypoint.sh"]