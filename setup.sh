#!/usr/bin/env bash
set -euo pipefail

readonly APP_NAME="linux-setup-automation"
readonly TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
readonly CONFIG_DIR="${HOME:-/tmp}/.config/${APP_NAME}"
readonly PROFILES_DIR="${CONFIG_DIR}/profiles"
readonly BACKUP_DIR="${CONFIG_DIR}/backups"
readonly USER_FALLBACK_LOG_DIR="${CONFIG_DIR}/logs"
readonly SWAPFILE_PATH="/swapfile"

NONINTERACTIVE="false"
DRY_RUN="false"
USE_UI_MODE="text"
REPO_UPDATED="false"

declare -a SELECTED_MODULES=()
declare -a OPTIMIZATION_OPTIONS=()
declare -A PROFILE_DATA=()

BASE_DIR="$(dirname "$(readlink -f "$0")")"
source "${BASE_DIR}/lib/core.sh"
source "${BASE_DIR}/lib/ui.sh"
source "${BASE_DIR}/lib/packages.sh"
source "${BASE_DIR}/lib/tasks.sh"

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --non-interactive) NONINTERACTIVE="true"; USE_UI_MODE="text" ;;
            --dry-run) DRY_RUN="true" ;;
            --profile) shift; safe_read_config "${PROFILES_DIR}/$1.conf" || exit 1 ;;
            *) log "ERR" "Opção desconhecida: $1"; exit 1 ;;
        esac
        shift
    done
}

main() {
    parse_args "$@"
    mkdir -p "${PROFILES_DIR}" "${BACKUP_DIR}" "${USER_FALLBACK_LOG_DIR}"
    init_logging

    log "INFO" "Iniciando Automação..."
    detect_os_and_pkg

    if [[ "${NONINTERACTIVE}" == "false" && -z "${SELECTED_MODULES[*]:-}" ]]; then
        if command -v whiptail >/dev/null; then USE_UI_MODE="whiptail"; fi
        
        local mods
        mods="$(ui_checklist "Módulos" "Escolha:" "base" "Sistema Base" "ON" "dev" "Desenvolvimento" "OFF")"
        read -r -a SELECTED_MODULES <<< "${mods}"
        [[ ${#SELECTED_MODULES[@]} -eq 0 ]] && SELECTED_MODULES=("base")
        
        ui_confirm "Confirmar" "Aplicar as configurações selecionadas?" || exit 0
    elif [[ -z "${SELECTED_MODULES[*]:-}" ]]; then
        SELECTED_MODULES=("base")
        OPTIMIZATION_OPTIONS=()
    fi

    for mod in "${SELECTED_MODULES[@]}"; do
        case "${mod}" in
            base) install_module_base ;;
        esac
    done

    for opt in "${OPTIMIZATION_OPTIONS[@]}"; do
        case "${opt}" in
            swapfile) configure_swapfile ;;
        esac
    done

    log "OK" "Execução finalizada com sucesso."
}

main "$@"
