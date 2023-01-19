#!/bin/bash -l
set -o errexit -o nounset -o xtrace

cd $APP_HOME
wget https://packages.redirection.io/dist/stable/2/any/redirectionio-agent-latest_any_amd64.tar.gz
tar xvzf redirectionio-agent-latest_any_amd64.tar.gz
rm -rf redirectionio-agent-latest_any_amd64.tar.gz

envsubst < template.agent.yml > agent.yml
