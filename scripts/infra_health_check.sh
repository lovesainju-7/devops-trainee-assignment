#!/bin/bash


echo "===== Resource Utilization ====="

# CPU usage
CPU=$(top -bn2 -d 0.5 | grep "Cpu(s)" | tail -1 | awk '{printf "%.0f", 100-$8}')

# RAM usage
RAM=$(free | grep "Mem:" | awk '{printf "%.0f", $3/$2*100}')

# Root disk usage
DISK=$(df / | grep "/$" | awk '{print $5}')

echo "CPU Usage: $CPU%"
echo "RAM Usage: $RAM%"
echo "Root Disk Usage: $DISK"

echo
echo

echo "===== Docker Status ====="

APP_CONTAINER="devops-backend"

# Check Docker
if systemctl is-active --quiet docker; then
    echo "Docker is Running"
else
    echo "Docker is Not Running"
fi
# Check Application
if docker ps --format '{{.Names}}' | grep -q "^$APP_CONTAINER$"
then
    echo "Application: Running"
else
    echo " Application container is stopped"
fi

echo
echo

echo "===== Health Check ====="

LIMIT=10
LOG_FILE="/var/log/infra_health.log"

DISK=$(df / | grep "/$" | awk '{printf "%.0f", $5+0}')
echo "Root Disk Usage: $DISK%"

if [ "$DISK" -gt "$LIMIT" ]
then
    echo "[WARNING] Disk usage is above $LIMIT%"

    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] Disk usage is $DISK%" >> "$LOG_FILE"
else
    echo "Disk usage is OK"
fi
