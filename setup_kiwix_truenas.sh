#!/bin/sh
# setup_kiwix_truenas.sh
# Script to create file structure and install Kiwix on TrueNAS

# Adjust this to your pool name
POOL="tank"
BASE="/mnt/${POOL}/kiwix"
TOOLS_DIR="${BASE}/tools"

# Create folder structure
echo "Creating Kiwix directories under ${BASE}..."
mkdir -p "${BASE}/content"
mkdir -p "${BASE}/config"
mkdir -p "${BASE}/logs"
mkdir -p "${BASE}/downloads"
mkdir -p "${TOOLS_DIR}"

# Optional: create a dedicated kiwix user (if not already exists)
if ! id "kiwix" >/dev/null 2>&1; then
  echo "Creating user 'kiwix'..."
  pw useradd kiwix -m -s /usr/sbin/nologin
fi

# Set ownership and permissions
echo "Setting ownership and permissions..."
chown -R kiwix:kiwix "${BASE}"
chmod -R 755 "${BASE}"

# Download latest kiwix-tools release
echo "Fetching latest Kiwix tools..."
LATEST_URL=$(fetch -o - https://api.github.com/repos/kiwix/kiwix-tools/releases/latest \
  | grep "browser_download_url" \
  | grep "x86_64-linux-gnu.tar.gz" \
  | cut -d '"' -f 4)

if [ -n "$LATEST_URL" ]; then
  echo "Downloading: $LATEST_URL"
  fetch -o "${TOOLS_DIR}/kiwix-tools.tar.gz" "$LATEST_URL"
  echo "Extracting..."
  tar -xzf "${TOOLS_DIR}/kiwix-tools.tar.gz" -C "${TOOLS_DIR}"
  rm "${TOOLS_DIR}/kiwix-tools.tar.gz"
else
  echo "❌ Could not fetch latest Kiwix tools URL!"
fi

echo "Kiwix setup complete!"
echo "Directory structure:"
ls -l "${BASE}"
