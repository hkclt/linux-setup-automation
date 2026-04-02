#!/usr/bin/env bash
set -e

REPO_URL="https://raw.githubusercontent.com/hkclt/linux-setup-automation/main"

WORK_DIR="/tmp/linux-setup-automation"
mkdir -p "${WORK_DIR}/lib"

echo "[*] Baixando módulos do repositório..."

curl -sL "${REPO_URL}/setup.sh" -o "${WORK_DIR}/setup.sh"
curl -sL "${REPO_URL}/lib/core.sh" -o "${WORK_DIR}/lib/core.sh"
curl -sL "${REPO_URL}/lib/ui.sh" -o "${WORK_DIR}/lib/ui.sh"
curl -sL "${REPO_URL}/lib/packages.sh" -o "${WORK_DIR}/lib/packages.sh"
curl -sL "${REPO_URL}/lib/tasks.sh" -o "${WORK_DIR}/lib/tasks.sh"

chmod +x "${WORK_DIR}/setup.sh"

echo "[*] Iniciando automação..."
cd "${WORK_DIR}"
exec ./setup.sh "$@"
