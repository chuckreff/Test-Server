#!/bin/sh
# setup_kiwix_truenas.sh
# Script to create file structure for Kiwix on TrueNAS

# Adjust this to your pool name
POOL="tank"
BASE="/mnt/${POOL}/kiwix"

# Create folder structure
echo "Creating Kiwix directories under ${BASE}..."
mkdir -p "${BASE}/content"
mkdir -p "${BASE}/config"
mkdir -p "${BASE}/logs"
mkdir -p "${BASE}/downloads"

# Optional: create a dedicated kiwix user (if not already exists)
if ! id "kiwix" >/dev/null 2>&1; then
  echo "Creating user 'kiwix'..."
  pw useradd kiwix -m -s /usr/sbin/nologin
fi

# Set ownership and permissions
echo "Setting ownership and permissions..."
chown -R kiwix:kiwix "${BASE}"
chmod -R 755 "${BASE}"

echo "Kiwix directory setup complete!"
echo "Structure:"
ls -l "${BASE}"
