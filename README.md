# Baïkal Docker-Image

Automatisch gebautes Image von [sabre-io/Baikal](https://github.com/sabre-io/Baikal),
veröffentlicht unter `ghcr.io/arthurbaer/baikal`.

Baïkal ist ein schlanker CalDAV- und CardDAV-Server. Er bietet eine umfangreiche Weboberfläche, über die sich Benutzer, Adressbücher und Kalender einfach verwalten lassen. Die Installation ist schnell und unkompliziert und erfordert lediglich einen einfachen PHP-fähigen Server. Die Daten können in einer MySQL-, PostgreSQL- oder SQLite-Datenbank gespeichert werden.

Mit Baïkal greifst du nahtlos von jedem Gerät auf deine Kontakte und Kalender zu. Er ist kompatibel mit iOS, macOS, DAVx5 unter Android, Mozilla Thunderbird und jeder anderen Anwendung, die CalDAV und CardDAV unterstützt. Schütze deine Privatsphäre, indem du Kalender und Kontakte selbst hostest – mit Baïkal.

## Verwendung

```bash
mkdir -p data/config data/Specific/db
chown -R 33:33 data

docker run -d --name baikal -p 8080:80 \
  -v ./data/config:/var/www/baikal/config \
  -v ./data/Specific:/var/www/baikal/Specific \
  ghcr.io/arthurbaer/baikal:0.13.0
```

Einrichtungsassistent: `http://HOST:8080/admin/`

- Die Host-Verzeichnisse müssen `www-data` (UID/GID 33) gehören.
- Der Ordner `Specific/db` muss auf dem Host selbst angelegt werden, sonst überdeckt das leere Volume ihn und Baïkal kann die Datenbank nicht erstellen.
- Verfügbare Versionen: siehe [Packages](https://github.com/arthurbaer?tab=packages). `latest` zeigt immer auf die neueste.

## Echte Client-IP hinter einem Reverse Proxy

Läuft Baïkal hinter einem Reverse Proxy (z. B. NPMplus, nginx, Traefik, Caddy), sieht Apache standardmäßig nur die IP des Proxys. Mit `REMOTEIP_TRUSTED_PROXIES` übernimmt das Image die echte Client-IP aus dem `X-Forwarded-For`-Header, sodass sie in den Logs erscheint. Die Funktion ist **standardmäßig aus**: Solange die Variable nicht gesetzt ist, wird keinem Proxy vertraut.

| Variable | Standard | Beschreibung |
|---|---|---|
| `REMOTEIP_TRUSTED_PROXIES` | *(leer, Funktion aus)* | Netz(e) deines Reverse Proxys als CIDR, mehrere mit Komma getrennt, z. B. `172.16.4.0/24,10.0.0.0/24` |
| `REMOTEIP_HEADER` | `X-Forwarded-For` | Header, aus dem die Client-IP gelesen wird |

Beispiel:

```bash
docker run -d --name baikal -p 8080:80 \
  -e REMOTEIP_TRUSTED_PROXIES=172.16.4.0/24 \
  -v ./data/config:/var/www/baikal/config \
  -v ./data/Specific:/var/www/baikal/Specific \
  ghcr.io/arthurbaer/baikal:0.13.0
```

Das passende Netz findest du, indem du die Funktion zunächst ausgeschaltet lässt und in `docker logs <container>` die erste Spalte ansiehst: Das ist die Adresse, über die dein Proxy Baikal erreicht. Nach dem Setzen der Variable steht dort die echte Client-IP.

> **Sicherheitshinweis:** Trage nur das Netz deines eigenen Reverse Proxys ein, niemals `0.0.0.0/0` oder `::/0`. Sonst kann jeder Client seine IP über einen selbst gesendeten Header fälschen. Dein Proxy muss den Header außerdem selbst setzen (NPMplus, nginx und Traefik tun das standardmäßig).

## Selbst bauen

```bash
docker build --build-arg BAIKAL_VERSION=0.13.0 -t baikal:0.13.0 .
```

Die Build-Pipeline (`.github/workflows/build.yml`) prüft regelmäßig auf neue
Baïkal-Releases und baut das Image automatisch.
