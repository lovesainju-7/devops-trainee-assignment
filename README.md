#  DevOps Trainee Assignment

This repo contains my completed work for the IT Infrastructure & DevOps trainee assignment. Below is a summary of what I set up and configured, along with the commands used to verify each part.

**To SSH into the server:**

```bash
ssh -i lovekeypair.pem -p 2222 trainee@ip-address
```
>  If you need the IP address, please contact me via email: lovesainju70@gmail.com

---

##  Task 1 – System Provisioning & Linux Administration

- Created a dedicated `trainee` user and added it to the `sudo` group.
- Set up SSH key-based authentication and switched SSH to run on port `2222` instead of the default `22`.
- Disabled direct root login over SSH (`PermitRootLogin no`).
- Enabled UFW and only allowed the ports actually needed: `2222` (SSH), `80` (HTTP), and `443` (HTTPS). Everything else is denied by default.

** Verify:**

```bash
groups trainee
sudo sshd -T | grep permitrootlogin
sudo ss -tlnp | grep 2222
sudo ufw status verbose
```

---

##  Task 2 – Containerization & Web Application

- Built a multi-container stack with Docker Compose: Nginx (reverse proxy), a Node.js backend, and PostgreSQL with a persistent volume.
- Nginx is exposed on host port `80` and forwards requests to the Node.js app running internally on port `5000`.
- Backend and database ports are not published to the host — only Nginx is reachable from outside.

** Build and run:**

```bash
cd ~/devops-trainee-assignment
docker compose build
docker compose up -d
```

** Verify:**

```bash
docker compose ps
docker volume ls
docker volume inspect devops-trainee-assignment_postgres_data
curl http://localhost/
curl http://localhost/health
```

---

##  Task 3 – Automation & Health Check

- Wrote `scripts/infra_health_check.sh` and deployed it to `/opt/scripts/infra_health_check.sh`.
- The script checks CPU usage, RAM usage, root disk usage, whether the Docker service is running, and whether the app container is running.
- If disk usage goes over `85%`, or the app container isn't running, it prints a `[WARNING]` and logs a timestamped entry to `/var/log/infra_health.log`.
- Set up a cron job to run the script automatically every 15 minutes.

** Run it and check the log:**

```bash
sudo chmod +x /opt/scripts/infra_health_check.sh
sudo /opt/scripts/infra_health_check.sh
sudo cat /var/log/infra_health.log
```

** To run the script every 15 minutes:**

```bash
*/15 * * * * /opt/scripts/infra_health_check.sh
```

---

##  Task 4 – Monitoring & Backups

- Wrote `scripts/db_backup.sh` and deployed it to `/opt/scripts/db_backup.sh` to dump, compress, and store the PostgreSQL database.
- Set up Prometheus and Node Exporter for basic system/container metrics.

** Run it and check the result:**

```bash
sudo chmod +x /opt/scripts/db_backup.sh
sudo /opt/scripts/db_backup.sh
sudo ls -lh /var/backups/db/
file /var/backups/db/db_backup_20260911.sql.gz
sudo gzip -dc /var/backups/db/db_backup_20260911.sql.gz | head
```

** Restore command:**

```bash
sudo gzip -dc /var/backups/db/db_backup_YYYYMMDD.sql.gz | docker exec -i devops-postgres psql -U trainee -d trainee_db
```

** Monitoring check:**

```bash
docker compose up -d
docker compose ps
curl http://localhost:9100/metrics
```

Prometheus UI: `http://SERVER_PUBLIC_IP:9090/targets` for targets page — Node Exporter shows as **UP**.

---

##  Task 5 – Git & Documentation

- Initialized the repo and worked in feature branches, merged cleanly into `main`.
