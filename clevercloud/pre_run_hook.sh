#!/bin/bash -l
set -o errexit -o nounset -o xtrace

cd $APP_HOME
export RIO_KEEP_ALIVE_ENABLED=${RIO_KEEP_ALIVE_ENABLED:-true}
export RIO_ALLOW_INVALID_CERTIFICATES=${RIO_ALLOW_INVALID_CERTIFICATES:-false}

if [[ "${RIO_TRUSTED_PROXIES:-}" == "USE_CC_REVERSE_PROXY_IPS" ]]; then
  export RIO_TRUSTED_PROXIES=${CC_REVERSE_PROXY_IPS:-}
fi

envsubst < template.agent.yml > agent.yml

if [[ "${RIO_TRUSTED_PROXIES:-}" != "" ]]; then
  sed -i'.no-proxies' "s/#trusted_proxies:/trusted_proxies:/g" agent.yml
fi
