#!/bin/bash -l
set -o errexit -o nounset -o xtrace

cd $APP_HOME
RIO_KEEP_ALIVE_ENABLED=${RIO_KEEP_ALIVE_ENABLED:-true}
envsubst < template.agent.yml > agent.yml

if [[ "${RIO_TRUSTED_PROXIES:-}" != "" ]]; then
  sed -i'.no-proxies' "s/#trusted_proxies:/trusted_proxies:/g" agent.yml
fi
