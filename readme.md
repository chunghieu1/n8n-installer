# n8n Installer

This script automates the installation and configuration of [n8n](https://n8n.io/) using Docker and Caddy on an Ubuntu server.

## Prerequisites

- You must have root privileges to run this script.
- Your domain or subdomain must be pointed to the server's public IP address.
- The script is designed for Ubuntu systems with `apt` package manager.

## Usage

Run the following command as root:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/chunghieu1/n8n-installer/refs/heads/main/install_n8n.sh)
```

## What the Script Does

1. Checks for root privileges.
2. Prompts for your domain or subdomain and verifies DNS is correctly pointed.
3. Installs required packages (`docker`, `docker-compose`, etc.).
4. Sets up the n8n directory structure.
5. Creates a `docker-compose.yml` and `Caddyfile` for n8n and Caddy reverse proxy.
6. Starts the n8n and Caddy services using Docker Compose.
7. Displays the access URL for your n8n instance.

## Notes

- Ensure your server has internet access to download necessary packages and Docker images.
- The script configures Caddy to automatically provide HTTPS for your domain.
- Default timezone is set to `Asia/Ho_Chi_Minh`. You can modify this in the script if needed.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.