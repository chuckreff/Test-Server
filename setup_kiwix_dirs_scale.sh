#!/bin/bash
# setup_kiwix_dirs_scale.sh
# Create file structure for Kiwix on TrueNAS SCALE (Linux)

set -euo pipefail

POOL="${1:-tank}"         # Default pool is 'tank'
BASE="/mnt/${POOL}/kiwix"

echo "👉 Creating Kiwix directories under ${BASE}..."

# Create directory structure
mkdir -p "${BASE}/content"    # ZIM files
mkdir -p "${BASE}/config"     # Config files
mkdir -p "${BASE}/logs"       # Logs
mkdir -p "${BASE}/downloads"  # Staging downloads
mkdir -p "${BASE}/tools"      # Kiwix binaries

# Create system user if missing
if ! id kiwix >/dev/null 2>&1; then
  echo "👉 Creating service user 'kiwix'..."
  useradd -r -s /usr/sbin/nologin kiwix
fi

# Set permissions
echo "👉 Setting ownership and permissions..."
chown -R kiwix:kiwix "${BASE}"
chmod -R 755 "${BASE}"

echo "✔ Kiwix directory structure setup complete!"
echo "You now have:"
ls -R "${BASE}"
