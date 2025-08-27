#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script needs to be run with root privileges"
   exit 1
fi

check_domain() {
    local domain=$1
    local server_ip=$(curl -s https://api.ipify.org)
    local domain_ip=$(dig +short $domain)

    if [ "$domain_ip" = "$server_ip" ]; then
        return 0
    else
        return 1
    fi
}

read -p "Enter your domain or subdomain: " DOMAIN

if check_domain $DOMAIN; then
    echo "Domain $DOMAIN has been correctly pointed to this server. Continuing installation"
else
    echo "Domain $DOMAIN has not been pointed to this server."
    echo "Please update your DNS record to point $DOMAIN to IP $(curl -s https://api.ipify.org)"
    echo "After updating the DNS, run this script again"
    exit 1
fi

N8N_DIR="/home/n8n"

export DEBIAN_FRONTEND=noninteractive
apt-get update -yq
apt-get install -yq apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -yq
apt-get install -yq docker-ce docker-ce-cli containerd.io docker-compose

mkdir -p $N8N_DIR

cat << EOF > $N8N_DIR/docker-compose.yml
version: "3"
services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    environment:
      - N8N_HOST=${DOMAIN}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${DOMAIN}
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_DIAGNOSTICS_ENABLED=false
    volumes:
      - $N8N_DIR:/home/node/.n8n
    networks:
      - n8n_network
    dns:
      - 8.8.8.8
      - 1.1.1.1

  caddy:
    image: caddy:2
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - $N8N_DIR/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - n8n
    networks:
      - n8n_network

networks:
  n8n_network:
    driver: bridge

volumes:
  caddy_data:
  caddy_config:
EOF

cat << EOF > $N8N_DIR/Caddyfile
${DOMAIN} {
    reverse_proxy n8n:5678
}
EOF

chown -R 1000:1000 $N8N_DIR
chmod -R 755 $N8N_DIR

cd $N8N_DIR
docker-compose up -d

echo ""
echo "╔═════════════════════════════════════════════════════════════╗"
echo "║                                                              "
echo "║     N8n đã được cài đặt thành công!                          "
echo "║                                                              "
echo "║      Truy cập: https://${DOMAIN}                             "
echo "║                                                              "
echo "╚═════════════════════════════════════════════════════════════╝"
echo ""