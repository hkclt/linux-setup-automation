#!/usr/bin/env bash

ui_confirm() {
    local title="$1" msg="$2"
    
    if [[ "${NONINTERACTIVE}" == "true" ]]; then
        log "INFO" "[Auto-Yes] Confirmação aceita: ${title}"
        return 0 
    fi

    if [[ "${USE_UI_MODE}" == "whiptail" ]]; then
        whiptail --title "${title}" --yesno "${msg}" 14 72
    else
        local ans
        printf '\e[36m[%s]\e[0m %s [y/N]: ' "${title}" "${msg}"
        read -r ans
        [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
    fi
}

ui_checklist() {
    local title="$1" prompt="$2"; shift 2
    
    if [[ "${NONINTERACTIVE}" == "true" ]]; then
        return 0
    fi

    if [[ "${USE_UI_MODE}" == "whiptail" ]]; then
        whiptail --title "${title}" --checklist "${prompt}" 22 80 12 "$@" 3>&1 1>&2 2>&3 | tr -d '"'
    else
        printf '\n\e[1m=== %s ===\e[0m\n%s\n' "${title}" "${prompt}"
        local i=1 choices=()
        while (( $# > 0 )); do
            printf '%d) %s - %s\n' "$i" "$1" "$2"
            choices[$i]="$1"; shift 3; ((i++))
        done
        printf 'Opções separadas por espaço: '
        read -r ans
        for num in $ans; do printf '%s ' "${choices[$num]:-}"; done
    fi
}
