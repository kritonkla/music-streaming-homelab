# Complete music streaming service using your own homeserver

This project uses Navidrome, filebrowser, caddy, crowdsec, beszel, uptime kuma, restic and rclone for the complete environment.

This repository demonstrates the deployment, security hardening, and automated recovery of a self-hosted software stack. 

## Architecture & Security

All services are fully containerized using Docker and sit behind a strict security perimeter managed by Caddy and CrowdSec.

*   **Music Streaming:** Navidrome acts as a web-based music collection manager and streamer.
*   **File Browser:** Filebrowser handles music/files upload to your server folder.
*   **Reverse Proxy & TLS:** Caddy handles all external routing and automatic SSL/TLS termination. 
*   **Active Intrusion Prevention (IPS):** CrowdSec continuously parses Caddy's access logs. It automatically identifies and bans malicious IP addresses globally.
*   **404 Trap:** Caddy is configured with a honeypot at the root domain that instantly drops automated vulnerability scanners and feeds them to CrowdSec.


## Backup Recovery Pipeline

A fully automated, backup pipeline without relying on local hardware.

*   **Restic:** Handles the creation of heavily encrypted, deduplicated snapshots of critical Docker volumes and configuration directories.
*   **Rclone:** Acts as the transport layer, utilizing a custom Google Cloud API Client ID to securely push Restic chunks to a Google Drive cloud storage.
*   **Retention Policies:** Automated cron jobs prune old snapshots, maintaining daily and weekly backups to optimize cloud storage limits.

## Technology Stack

*   **Containerization:** Docker, Docker Compose
*   **Networking / Proxy:** Caddy, Tailscale (Internal VPN routing)
*   **Security:** CrowdSec
*   **Monitoring:** Beszel (System resources), Uptime Kuma (Service health)
*   **Media & Files:** Navidrome, FileBrowser
*   **Backup / CI:** Bash, Restic, Rclone

## Deployment

1. Clone this repository to the host machine.
2. Copy `.env.example` to `.env` and populate it.
3. Deploy the stack:
   ```bash
   ./build-caddy.sh
   ```
   docker compose up -d
4. Add backup.sh to your server's cron jobs.

## Configure CrowdSec & Caddy
To allow Caddy to dynamically block malicious traffic, it needs a Local API (LAPI) key to communicate with the CrowdSec container.

1. Bring up the CrowdSec container first:
   ```bash
   docker compose up -d crowdsec
   ```
2. Generate a new bouncer API key:
    ```bash
    docker exec crowdsec cscli bouncers add caddy-bouncer
    ```
3. The terminal will output an alphanumeric key. Copy this key and paste it into CROWDSEC_API_KEY in .env

Once the key is saved, you can safely deploy the rest of the stack.

## Configure Beszel
Beszel operates using a Hub-and-Agent architecture. To allow the monitoring agent to securely report your server's metrics to the dashboard, you need to generate a cryptographic key.

1. Bring up the Beszel Hub first:
   ```bash
   docker compose up -d beszel
   ```
2. Navigate to the Beszel web interface and create your admin account.
3. In the dashboard, click Add System to register your server.
4. Beszel will generate a unique key for this system. Copy this key and paste it into BESZEL_KEY in .env (You can also use Token instead)
5. Deploy the agent to begin tracking:
    ```bash
    docker compose up -d beszel-agent
    ```

## Backup Configuration (Prerequisites)

Before running the backup script or deploying the stack, you must initialize the Rclone remote and Restic repository.

### 1. Configure Rclone (Google Drive)
To prevent API rate limiting, it is highly recommended to use a custom Google Cloud Client ID.
1. Generate an OAuth 2.0 Client ID and Secret from the Google Cloud Console (Desktop application).
2. Run the Rclone configuration wizard on your host machine:
   ```bash
   rclone config
   ```
3. Create a new remote named _gdrive_.
4. Select _drive_ (Google Drive) as the storage type.
5. Paste your Client ID and Client Secret when prompted.
6. Complete the web authentication to link your personal Google Drive account.

### 2. Initialize the Restic Repository

Once Rclone is authenticated, you must initialize the Restic repository in your Google Drive to prepare it for snapshots.
1. Export your chosen secure password:
    ```bash
    export RESTIC_PASSWORD="your_secure_password"
    ```
2. Initialize the repository through Rclone:
    ```bash
    restic -r rclone:gdrive:your_backup_repo init
    ```
