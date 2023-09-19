# Redirection.io Proxy for Clever Cloud

## DNS

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
clever domain -a proxy favourite set your.domain.com
```

Flavor can be `nano` if `pico` is too small, or `XS/S` to avoid shared CPU or for a more stable instance for high traffic

Be careful! We use our repository to deploy the proxies! Clone it and use your own if needed!

### Environment variables

Don't forget to update them!

```bash
clever env -a proxy set CC_RUN_COMMAND "./redirection-agent/redirectionio-agent --config-file ./agent.yml"
clever env -a proxy set CC_PRE_BUILD_HOOK "./clevercloud/pre_build_hook.sh"
clever env -a proxy set CC_PRE_RUN_HOOK "./clevercloud/pre_run_hook.sh"
clever env -a proxy set PORT "8080"
clever env -a proxy set RIO_INSTANCE_NAME "CleverCloud"
clever env -a proxy set RIO_PRESERVE_HOST "false"
clever env -a proxy set RIO_ADD_RULE_IDS_HEADER "true"
clever env -a proxy set RIO_COMPRESS "true"
clever env -a proxy set RIO_REQUEST_BODY_SIZE_LIMIT "200MB"
clever env -a proxy set RIO_LOG_LEVEL "info"
clever env -a proxy set RIO_PROJECT_KEY "RIO PROJECT KEY"
clever env -a proxy set RIO_FORWARD "http://…cleverapps.io/"
clever env -a proxy set RIO_TRUSTED_PROXIES ""
```

`RIO_FORWARD` is in `http`! Not `https`. It is mandatory!

The `Pre Build` hook downloads the latest redirectionio binary. If you want to force a new version of the agent, force rebuild it.

The `Pre Run` hook creates the `agent.yml` configuration file.

#### Behind a proxy like Cloudflare

You need to declare your proxy's IP addresses.

For Cloudflare: (see https://www.cloudflare.com/fr-fr/ips/)

```
clever env -a proxy set RIO_TRUSTED_PROXIES "173.245.48.0/20,103.21.244.0/22,103.22.200.0/22,103.31.4.0/22,141.101.64.0/18,108.162.192.0/18,190.93.240.0/20,188.114.96.0/20,197.234.240.0/22,198.41.128.0/17,162.158.0.0/15,104.16.0.0/13,104.24.0.0/14,172.64.0.0/13,131.0.72.0/22"
```

### Start the proxy

```bash
clever restart --without-cache -a proxy
```

## Changes to be made on a Symfony app

Change the framework config:

```
framework:
    trusted_proxies: '%env(CC_REVERSE_PROXY_IPS)%,%env(TRUSTED_PROXIES)%'
    trusted_headers: [ 'x-forwarded-for', 'x-forwarded-host', 'x-forwarded-proto', 'x-forwarded-port', 'x-forwarded-prefix' ]
```

And add two variables in the `.env`:

```
TRUSTED_PROXIES=

###> clevercloud ###
CC_REVERSE_PROXY_IPS=127.0.0.1
###< clevercloud ###
```

The `CC_REVERSE_PROXY_IPS` is defined automatically by CleverCloud, cf [documentation](https://www.clever-cloud.com/doc/reference/reference-environment-variables/#set-by-the-deployment-process).

But, the proxy IP is not in this list, and we trust it to get the client IP. We have several solutions:

1. Set the env variable `TRUSTED_PROXIES=REMOTE_ADDR` on the PHP app in Clever:

```
clever env -a prod set TRUSTED_PROXIES "REMOTE_ADDR"
clever restart --without-cache -a prod
```

We trust **all proxies**, but this is the easiest solution for the moment.

2. Use [Tailscale](https://www.clever-cloud.com/doc/reference/reference-environment-variables/#tailscale-support) to create a private VPN with the proxy and the PHP apps. But we don't have any feedback performances on exchanges between apps. 

3. Wait for Clever Cloud to support VPCs. According to our information, this is on their roadmap.
 
## Troubleshooting

### The app keeps redirecting to the CC domain (like `https://app-xxxxxx-xxxx-308021983139.cleverapps.io`)

Don't forget to uncheck the "Force HTTPS" in your app's Information.
You can also update it using : `clever config update --disable-force-https`
