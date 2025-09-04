#!/bin/bash
# setup_kiwix_truenas_scale.sh
# Create Kiwix file structure and install kiwix-tools on TrueNAS SCALE

set -euo pipefail

POOL="${1:-tank}"   # default pool name is 'tank'
BASE="/mnt/${POOL}/kiwix"
TOOLS_DIR="${BASE}/tools"

# --- Helpers ---
have_cmd() { command -v "$1" >/dev/null 2>&1; }
dl() {
  if have_cmd curl; then
    curl -fL "$1" -o "$2"
  elif have_cmd wget; then
    wget -O "$2" "$1"
  else
    echo "❌ Need curl or wget installed."; exit 1
  fi
}

# --- Layout ---
echo "👉 Creating Kiwix directories..."
mkdir -p "${BASE}/content" "${BASE}/config" "${BASE}/logs" "${BASE}/downloads" "${TOOLS_DIR}"

# Create kiwix user if not exists
if ! id kiwix >/dev/null 2>&1; then
  echo "👉 Creating service user 'kiwix'..."
  useradd -r -s /usr/sbin/nologin kiwix
fi

echo "👉 Setting ownership and permissions..."
chown -R kiwix:kiwix "${BASE}"
find "${BASE}" -type d -exec chmod 755 {} \;

# --- Download kiwix-tools ---
MIRROR="https://mirror.turnkeylinux.org/kiwix/release/kiwix-tools/"
TMP_HTML="$(mktemp)"

echo "👉 Fetching mirror index..."
dl "${MIRROR}" "${TMP_HTML}"

LATEST_TGZ=$(grep -o 'kiwix-tools_linux-x86_64-[^"]*\.tar\.gz' "${TMP_HTML}" | sort | tail -n1)
rm -f "${TMP_HTML}"

if [ -z "${LATEST_TGZ}" ]; then
  echo "❌ Could not find a Linux tarball on mirror."; exit 2
fi

echo "👉 Downloading latest kiwix-tools: ${LATEST_TGZ}"
dl "${MIRROR}${LATEST_TGZ}" "${TOOLS_DIR}/kiwix-tools.tar.gz"

echo "👉 Extracting..."
tar -xzf "${TOOLS_DIR}/kiwix-tools.tar.gz" -C "${TOOLS_DIR}"
rm -f "${TOOLS_DIR}/kiwix-tools.tar.gz"

LATEST_DIR="$(ls -d ${TOOLS_DIR}/kiwix-tools_linux-x86_64-* | sort | tail -n1)"
if [ -n "${LATEST_DIR}" ] && [ -x "${LATEST_DIR}/kiwix-serve" ]; then
  ln -sfn "${LATEST_DIR}/kiwix-serve" "${TOOLS_DIR}/kiwix-serve"
  chown -h kiwix:kiwix "${TOOLS_DIR}/kiwix-serve"
else
  echo "❌ Could not find kiwix-serve after extraction."; exit 3
fi

echo "✔ Kiwix setup complete!"
echo "Directory structure:"
ls -l "${BASE}"

echo "Next steps:"
echo "  1. Place .zim files in: ${BASE}/content"
echo "  2. Run test server:"
echo "       sudo -u kiwix ${TOOLS_DIR}/kiwix-serve --port=8080 ${BASE}/content/*.zim"
