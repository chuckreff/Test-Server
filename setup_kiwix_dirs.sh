#!/bin/bash
# setup_kiwix_dirs.sh
# Create file structure for Kiwix on TrueNAS SCALE

set -euo pipefail

POOL="${1:-tank}"       # Default pool name is 'tank' if not provided
BASE="/mnt/${POOL}/kiwix"

echo "👉 Creating Kiwix directories under ${BASE}..."

# Create directory structure
mkdir -p "${BASE}/content"    # ZIM files
mkdir -p "${BASE}/config"     # Config files
mkdir -p "${BASE}/logs"       # Logs
mkdir -p "${BASE}/downloads"  # Staging downloads
mkdir -p "${BASE}/tools"      # Binaries (if you install kiwix-tools later)

# Create a system user for Kiwix if missing
if ! id kiwix >/dev/null 2>&1; then
  echo "👉 Creating service user 'kiwix'..."
  useradd -r -s /usr/sbin/nologin kiwix
fi

# Set permissions
echo "👉 Setting ownership and permissions..."
chown -R kiwix:kiwix "${BASE}"
find "${BASE}" -type d -exec chmod 755 {} \;

echo "✔ Kiwix directory structure setup complete!"
echo "You now have:"
tree -d "${BASE}" || ls -R "${BASE}"
