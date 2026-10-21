# Baikal Docker-Image

Automatisch gebautes Image von [sabre-io/Baikal](https://github.com/sabre-io/Baikal),
veröffentlicht unter `ghcr.io/arthurbaer/baikal`.

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
- Den Ordner `Specific/db` muss auf dem Host selbst angelegt werden, sonst überdeckt das leere Volume und Baikal kann die Datenbank nicht erstellen.
- Verfügbare Versionen: siehe [Packages](https://github.com/arthurbaer?tab=packages). `latest` zeigt immer auf die neueste.

## Selbst bauen

```bash
docker build --build-arg BAIKAL_VERSION=0.13.0 -t baikal:0.13.0 .
```

Die Build-Pipeline (`.github/workflows/build.yml`) prüft regelmäßig auf neue
Baikal-Releases und baut das Image automatisch.
