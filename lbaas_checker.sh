# Comprehensive script that scans installed packages, DNS configurations, and running processes to check for best practices related to the 10 LBaaS operational issues.
# It generates a detailed report and guides next steps for identified issues.

# for details refer usage refer REDME file


#!/bin/bash

# Ensure script is run as root for full access
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Variables
REPORT="lbaas_report_$(hostname)_$(date +%Y%m%d_%H%M%S).txt"
TMP_FILE="/tmp/lbaas_scan.tmp"
HOSTNAME=$(hostname)
DATE=$(date)

# Initialize report
echo "Load Balancer as a Service (LBaaS) Best Practices Report" > $REPORT
echo "Host: $HOSTNAME" >> $REPORT
echo "Date: $DATE" >> $REPORT
echo "----------------------------------------" >> $REPORT

# Function to check installed packages
check_packages() {
    echo "Checking installed packages for LBaaS components..." >> $REPORT
    PACKAGES=("haproxy" "nginx" "keepalived" "openstack-lbaas")
    for pkg in "${PACKAGES[@]}"; do
        if dpkg -l | grep -q "$pkg"; then
            echo "[OK] $pkg is installed." >> $REPORT
        else
            echo "[WARN] $pkg is NOT installed." >> $REPORT
        fi
    done
}

# Function to check DNS configurations
check_dns() {
    echo "Checking DNS resolution..." >> $REPORT
    RESOLVER=$(cat /etc/resolv.conf | grep -v "^#" | grep nameserver)
    if [ -n "$RESOLVER" ]; then
        echo "[OK] DNS resolvers are configured: $RESOLVER" >> $REPORT
    else
        echo "[WARN] No DNS resolvers found in /etc/resolv.conf." >> $REPORT
    fi
}

# Function to check running processes
check_processes() {
    echo "Checking running processes for LBaaS components..." >> $REPORT
    SERVICES=("haproxy" "nginx" "keepalived")
    for svc in "${SERVICES[@]}"; do
        if pgrep -x "$svc" > /dev/null; then
            echo "[OK] $svc is running." >> $REPORT
        else
            echo "[WARN] $svc is NOT running." >> $REPORT
        fi
    done
}

# Function to check SSL/TLS certificates
check_ssl() {
    echo "Checking SSL/TLS configurations..." >> $REPORT
    CERT_FILES=$(find /etc -name "*.crt" -o -name "*.pem" 2>/dev/null)
    if [ -n "$CERT_FILES" ]; then
        echo "[OK] Found SSL/TLS certificates:" >> $REPORT
        echo "$CERT_FILES" >> $REPORT
    else
        echo "[WARN] No SSL/TLS certificates found." >> $REPORT
    fi
}

# Function to check scaling configurations
check_scaling() {
    echo "Checking scaling configurations..." >> $REPORT
    # Dummy example for autoscaling (customize as needed)
    AUTO_SCALING_CONFIG="/etc/autoscaling/config"
    if [ -f "$AUTO_SCALING_CONFIG" ]; then
        echo "[OK] Autoscaling is configured: $AUTO_SCALING_CONFIG" >> $REPORT
    else
        echo "[WARN] Autoscaling configuration file missing." >> $REPORT
    fi
}

# Function to check security
check_security() {
    echo "Checking security configurations..." >> $REPORT
    # Check for firewall rules (example)
    if iptables -L | grep -q "ACCEPT"; then
        echo "[OK] Firewall rules configured." >> $REPORT
    else
        echo "[WARN] No firewall rules detected. Consider securing ports." >> $REPORT
    fi
}

# Add more checks as necessary for other issues

# Run checks
check_packages
check_dns
check_processes
check_ssl
check_scaling
check_security

# Finish report
echo "----------------------------------------" >> $REPORT
echo "Report generated: $REPORT"
echo "Next Steps:" >> $REPORT
echo "1. Address WARN issues promptly." >> $REPORT
echo "2. Update missing or outdated configurations." >> $REPORT
echo "3. Review logs for further insights." >> $REPORT
echo "----------------------------------------" >> $REPORT

# Display report summary to user
cat $REPORT
