#!/bin/bash -l
set -o errexit -o nounset -o xtrace

cd $APP_HOME
envsubst < template.agent.yml > agent.yml
