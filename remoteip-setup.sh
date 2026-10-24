# Dieses Skript ermöglicht das Setzen eines vertrauenswürdigen Proxy-Server über die Variable "REMOTEIP_TRUSTED_PROXIES".
# Hintergrund ist das Durchreichen der externen IP des Clients, damit diese im Log von Baikal landen.
#!/bin/sh
set -e
CONF=/etc/apache2/conf-available/remoteip.conf

if [ -n "$REMOTEIP_TRUSTED_PROXIES" ]; then
  {
    echo "RemoteIPHeader ${REMOTEIP_HEADER:-X-Forwarded-For}"
    for p in $(echo "$REMOTEIP_TRUSTED_PROXIES" | tr ',' ' '); do
      echo "RemoteIPInternalProxy $p"
    done
  } > "$CONF"
else
  : > "$CONF"
fi

exec docker-php-entrypoint "$@"
