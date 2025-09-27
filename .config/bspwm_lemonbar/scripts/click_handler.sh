#!/bin/bash
###############################################################
# Archivo: ~/.config/bspwm_lemonbar_scripts/click_handler.sh
# Descripción: Recibe comandos desde lemonbar y los ejecuta
# Autor: Yandri Loor
# Fecha de cración: 19 de Septiembre del 2025
# Última modificación: 25 de Septiembre del 2025
###############################################################


while read -r cmd; do
    case "$cmd" in
        DESK_CHANGE_*)
            index="${cmd#DESK_CHANGE_}"
            mapfile -t DESKTOPS < <(bspc query -D --names)

            # Ajustar de 1-based (lemonbar) a 0-based (bash arrays)
            index=$((index - 1))

            DESK="${DESKTOPS[$index]}"

            if [ -n "$DESK" ]; then
                bspc desktop "$DESK" -f
            else
                echo "DEBUG: índice inválido: $index (ajustado)" >&2
                echo "DEBUG: escritorios actuales -> ${DESKTOPS[*]}" >&2
            fi
            ;;
        WIFI_NOTIFY)
            "$HOME/.config/bspwm_lemonbar/scripts/wifi_notify.sh" &
            ;;
        WIFI_MENU)
            "$HOME/.config/bspwm_lemonbar/scripts/wifi_menu.sh" &
            ;;
        ETH_NOTIFY)
            "$HOME/.config/bspwm_lemonbar/scripts/ethernet.sh" &
            ;;
        BLUETOOTH_NOTIFY)
            "$HOME/.config/bspwm_lemonbar/scripts/bluetooth_notify.sh" &
            ;;
        BLUETOOTH_MENU)
            "$HOME/.config/bspwm_lemonbar/scripts/bluetooth_menu.sh" &
            ;;
        SYSTEM_NOTIFY)
            "$HOME/.config/bspwm_lemonbar/scripts/system_notify.sh" &
            ;;
        SYSTEM_MENU)
            "$HOME/.config/bspwm_lemonbar/scripts/sys_maintenance/sys_menu.sh" &
            ;;
        POWER_MENU)
            "$HOME/.config/bspwm_lemonbar/scripts/power_menu.sh" &
            ;;	

	
        *)
            echo "Comando desconocido: $cmd" >&2
            ;;
    esac
done

