# Redirection.io Proxy for Clever Cloud

## DNS

All `*.preprod.monsieurbiz.cloud` domains are pointing to Clever Cloud on HTTP records.

For HTTP:
```
CNAME record: domain.par.clever-cloud.com.
A records: 185.42.117.108 185.42.117.109 46.252.181.103 46.252.181.104
```

For HTTP2: (first ask Clever Cloud support for activation!)
```
CNAME record: domain.par.secondary.services.clever-cloud.com.
A records: 185.42.117.123 46.252.181.120 46.252.181.180
```

## Setup on Clever Cloud

Run all these commands inside the project you are working on.
The proxy app will be linked using the `.clever.json` file.

### Application

```bash
clever create -a proxy -o "ORG NAME or ID" --type node --region par --github "monsieurbiz/redirectionio-proxy" "Proxy"
clever scale -a proxy --flavor pico
clever config -a proxy update --enable-zero-downtime --enable-cancel-on-push --enable-force-https
clever domain -a proxy add your.domain.com
clever domain -a proxy favourite set your.domain.com -a proxy
```

Flavor can be `nano` if `pico` is too small, or `XS/S` to avoid shared CPU or for a more stable instance for high traffic

### Environment variables

Don't forget to update them!

```bash
clever env -a proxy set CC_RUN_COMMAND "./redirection-agent/redirectionio-agent --config-file ./agent.yml"
clever env -a proxy set PORT "8080"
clever env -a proxy set RIO_INSTANCE_NAME "CleverCloud"
clever env -a proxy set RIO_PROJECT_KEY "RIO PROJECT KEY"
clever env -a proxy set RIO_FORWARD "http://…cleverapps.io/"
clever env -a proxy set RIO_PRESERVE_HOST "false"
clever env -a proxy set RIO_ADD_RULE_IDS_HEADER "true"
clever env -a proxy set RIO_COMPRESS "true"
clever env -a proxy set RIO_REQUEST_BODY_SIZE_LIMIT "200MB"
clever env -a proxy set RIO_LOG_LEVEL "info"
```

`RIO_PROJECT_FORWARD` is in `http`! Not `https`. It is mandatory!

### Deploy

```bash
clever deploy -a proxy
```

## Changes to be made on a Symfony app

Framework config:

```
framework:
    trusted_proxies: '%env(CC_REVERSE_PROXY_IPS)%'
    trusted_headers: [ 'x-forwarded-for', 'x-forwarded-host', 'x-forwarded-proto', 'x-forwarded-port', 'x-forwarded-prefix' ]
```

.env:

```
###> clevercloud ###
CC_REVERSE_PROXY_IPS=127.0.0.1
###< clevercloud ###
```
