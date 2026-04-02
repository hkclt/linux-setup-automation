#!/usr/bin/env bash

init_logging() {
    mkdir -p "${USER_FALLBACK_LOG_DIR}"
    LOG_FILE="${USER_FALLBACK_LOG_DIR}/${APP_NAME}-${TIMESTAMP}.log"
    touch "${LOG_FILE}" && chmod 600 "${LOG_FILE}" || true
}

log() {
    local level="$1"; shift
    printf '%s [%-5s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${level}" "$*" >> "${LOG_FILE}"
    case "${level}" in
        INFO) printf '\e[34m[INFO]\e[0m %s\n' "$*" ;;
        WARN) printf '\e[33m[WARN]\e[0m %s\n' "$*" >&2 ;;
        ERR)  printf '\e[31m[ERRO]\e[0m %s\n' "$*" >&2 ;;
        OK)   printf '\e[32m[ OK ]\e[0m %s\n' "$*" ;;
    esac
}

execute() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        log "INFO" "[DRY-RUN] Executaria: $*"
        return 0
    fi
    "$@"
}

execute_priv() {
    if [[ "${EUID}" -eq 0 ]]; then
        execute "$@"
    else
        execute sudo "$@"
    fi
}

safe_read_config() {
    local file="$1"
    [[ -f "${file}" ]] || return 1
    while IFS='=' read -r key val; do
        [[ -z "${key}" || "${key}" == \#* ]] && continue
        val="${val%\"}"; val="${val#\"}"
        val="${val%\'}"; val="${val#\'}"
        
        case "${key}" in
            ID) DISTRO_ID="${val}" ;;
            ID_LIKE) DISTRO_FAMILY="${val}" ;;
            PRETTY_NAME) DISTRO_NAME="${val}" ;;
            MODULES) read -r -a SELECTED_MODULES <<< "${val}" ;;
            DESKTOP_ENVIRONMENT) PROFILE_DATA[desktop_environment]="${val}" ;;
            OPTIMIZATIONS) read -r -a OPTIMIZATION_OPTIONS <<< "${val}" ;;
        esac
    done < "${file}"
}

backup_file() {
    local file="$1"
    [[ -e "${file}" ]] || return 0
    execute_priv cp -a "${file}" "${BACKUP_DIR}/$(basename "${file}").${TIMESTAMP}.bak"
    log "INFO" "Backup de ${file} criado."
}
