# Baikal Docker-Image

    docker build -t baikal:latest .
    docker run -d --name baikal -p 8080:80 \
      -v ./data/config:/var/www/baikal/config \
      -v ./data/Specific:/var/www/baikal/Specific \
      baikal:latest

Setup-Assistent: http://HOST:8080/admin/
Host-Verzeichnisse müssen www-data (UID/GID 33) gehören: `chown -R 33:33 data`
Andere Version: `--build-arg BAIKAL_VERSION=<tag>`
