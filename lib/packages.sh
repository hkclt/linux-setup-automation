#!/usr/bin/env bash

detect_os_and_pkg() {
    safe_read_config "/etc/os-release"
    
    if [[ "${DISTRO_ID}" == "arch" || "${DISTRO_FAMILY}" == *"arch"* ]]; then
        DISTRO_FAMILY="arch"; PKG_MANAGER="pacman"
    elif [[ "${DISTRO_ID}" == "bazzite" ]]; then
        DISTRO_FAMILY="bazzite"; PKG_MANAGER="rpm-ostree"
    elif [[ "${DISTRO_ID}" == "void" ]]; then
        DISTRO_FAMILY="void"; PKG_MANAGER="xbps"
    elif [[ "${DISTRO_ID}" == "debian" || "${DISTRO_ID}" == "ubuntu" || "${DISTRO_FAMILY}" == *"debian"* ]]; then
        DISTRO_FAMILY="debian"; PKG_MANAGER="apt"
    elif [[ "${DISTRO_ID}" == "fedora" || "${DISTRO_FAMILY}" == *"fedora"* ]]; then
        DISTRO_FAMILY="fedora"; PKG_MANAGER="dnf"
    else
        log "ERR" "Distribuição não suportada: ${DISTRO_NAME:-$DISTRO_ID}"
        exit 1
    fi
}

install_pkg() {
    local pkgs=("$@")
    [[ "${#pkgs[@]}" -eq 0 ]] && return 0

    if [[ "${REPO_UPDATED}" == "false" ]]; then
        log "INFO" "Atualizando repositórios..."
        case "${PKG_MANAGER}" in
            apt) execute_priv apt-get update -yqq ;;
            pacman) execute_priv pacman -Sy --noconfirm ;;
            dnf) execute_priv dnf makecache -y -q ;;
            rpm-ostree) execute_priv rpm-ostree refresh-md ;;
            xbps) execute_priv xbps-install -S ;;
        esac
        REPO_UPDATED="true"
    fi

    log "INFO" "Instalando pacotes via ${PKG_MANAGER}: ${pkgs[*]}"
    case "${PKG_MANAGER}" in
        apt) execute_priv env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${pkgs[@]}" ;;
        pacman) execute_priv pacman -S --noconfirm --needed "${pkgs[@]}" ;;
        dnf) execute_priv dnf install -y "${pkgs[@]}" ;;
        rpm-ostree) execute_priv rpm-ostree install --idempotent "${pkgs[@]}" ;;
        xbps) execute_priv xbps-install -y "${pkgs[@]}" ;;
    esac
}
