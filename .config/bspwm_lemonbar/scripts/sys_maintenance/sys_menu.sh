#!/bin/bash
#########################################################################
# Archivo: ~/.config/bspwm_lemonbar_scripts/sys_maintenance/sys_menu.sh
# Descripción: Menú de mantenimiento del sistema con rofi
# Autor: Yandri Loor
# Última modificación: 20 de Septiembre 2025
#########################################################################

ROFI_CMD="rofi -dmenu -i -theme ~/.config/rofi/sys_maintenance.rasi"
ROFI_MESSAGE="~/.config/rofi/message.rasi"

DIR="$HOME/.config/bspwm_lemonbar/scripts/sys_maintenance"

options=(
    " Limpiar caché de paquetes"
    " Eliminar paquetes huérfanos"
    " Ver servicios en ejecución"
    " Procesos pesados"
    " Estado RAM/Swap"
    "󰅖 Cancelar"
)

choice=$(printf '%s\n' "${options[@]}" | $ROFI_CMD -p "Mantenimiento")

show_message() {
    # Mensaje temporal con Rofi
    echo "$1" | rofi -dmenu -p "Info" -theme $ROFI_MESSAGE -mesg "$1" &
    sleep "${2:-5}"  # Tiempo por defecto 5s
    kill $! 2>/dev/null
}

case "$choice" in
    " Limpiar caché de paquetes")
        bash "$DIR/clean_cache.sh"
        show_message "✔ Caché de paquetes se ha limpiado con éxito." 5
        ;;
    " Eliminar paquetes huérfanos")
        bash "$DIR/clean_orphans.sh"
        show_message "✔ Paquetes huérfanos eliminados con éxito." 5
        ;;
    " Ver servicios en ejecución")
        # Terminal centrada (usando alacritty o gnome-terminal)
        
        alacritty -t sys_services -e bash -c "$DIR/check_services.sh; read -p 'Presiona Enter para cerrar...'" &
        ;;
        
    " Procesos pesados")
        alacritty -c "$DIR/kill_heavy.sh; read -p 'Presiona Enter para cerrar...'" &
        ;;

    " Estado RAM/Swap")
        bash "$DIR/ram_swap.sh" | rofi -dmenu -theme $ROFI_MESSAGE -mesg "Estado RAM/Swap" &
        
        sleep 5
        kill $! 2>/dev/null
        ;;
    *)
        exit 0
        ;;
esac
