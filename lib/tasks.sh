#!/usr/bin/env bash

install_module_base() {
    log "INFO" "Instalando Módulo: Base"
    local pkgs=()
    case "${DISTRO_FAMILY}" in
        debian) pkgs=(curl wget git unzip build-essential jq htop tree vim) ;;
        arch) pkgs=(curl wget git unzip base-devel jq htop tree vim) ;;
        fedora) pkgs=(curl wget git unzip @development-tools jq htop tree vim) ;;
        bazzite) pkgs=(curl wget git unzip jq htop tree vim) ;;
        void) pkgs=(curl wget git unzip base-devel jq htop tree vim) ;;
    esac
    install_pkg "${pkgs[@]}"
}

configure_swapfile() {
    log "INFO" "Configurando Swapfile"
    
    if swapon --show --noheadings 2>/dev/null | grep -q "${SWAPFILE_PATH}"; then
        log "WARN" "Swapfile já ativa."
        return 0
    fi

    execute_priv fallocate -l "2G" "${SWAPFILE_PATH}"
    
    if [[ "${DISTRO_FAMILY}" == "bazzite" ]]; then
        execute_priv chattr +C "${SWAPFILE_PATH}" 2>/dev/null || true
    fi

    execute_priv chmod 600 "${SWAPFILE_PATH}"
    execute_priv mkswap "${SWAPFILE_PATH}"
    execute_priv swapon "${SWAPFILE_PATH}"
    
    backup_file "/etc/fstab"
    if [[ "${DRY_RUN}" != "true" ]]; then
        if ! grep -q "[[:space:]]${SWAPFILE_PATH}[[:space:]]" /etc/fstab; then
            echo "${SWAPFILE_PATH} none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
        fi
    else
        log "INFO" "[DRY-RUN] Adicionaria swap ao fstab."
    fi
}
