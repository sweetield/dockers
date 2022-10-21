#!/bin/sh

#cctv版本
AUUID="ee1bd305-454d-45c9-8645-7563ad9192f2"
CADDYIndexPage="https://www.free-css.com/assets/files/free-css-templates/download/page265/shree.zip"
PORT=8080

VER=`wget -qO- "https://api.github.com/repos/XTLS/cctv-core/releases/latest" | sed -n -r -e 's/.*"tag_name".+?"([vV0-9\.]+?)".*/\1/p'`
mkdir /cctvbin && cd /cctvbin
cctv_URL="https://raw.githubusercontent.com/residenceclub/cctv/main/cctv.zip"
wget -N ${cctv_URL}
unzip -qq cctv.zip
rm -f cctv.zip
chmod +x ./cctv

# caddy-configs
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt

#CADDYIndexPage-configs
wget --quiet $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
cat /Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
cat /config.json | sed -e "s/\$AUUID/$AUUID/g" >/cctvbin/config.json
# 启动tor程序
tor &

# 启动cctv程序
/cctvbin/cctv -config /cctvbin/config.json &

# 启动caddy程序
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
