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
    local title="$1"
    local msg="$2"
    local timeout="${3:-5}"

    alacritty \
        --title "sys_message" \
        --class "sys_message" \
        --option window.dimensions.columns=45 \
        --option window.dimensions.lines=5 \
        -e bash -c "
            clear
            tput civis  # Ocultar cursor
            cols=\$(tput cols)

            # Título centrado
            printf '%*s\n\n' \$(( (cols+${#title})/2 )) '$title'

            # Texto normal (puede ser multilínea)
            echo -e '$msg'

            sleep $timeout
        " &
}

show_message1() {
    local title="$1"
    local msg="$2"
    local timeout="${3:-5}"

    alacritty \
        --title "sys_message" \
        --class "sys_message" \
        --option window.dimensions.columns=80 \
        --option window.dimensions.lines=25 \
        -e bash -c "
            clear
            tput civis  # Ocultar cursor
            cols=\$(tput cols)

            # Título centrado
            printf '%*s\n\n' \$(( (cols+${#title})/2 )) '$title'

            # Texto normal (puede ser multilínea)
            echo -e '$msg'

            sleep $timeout
        " &
}


case "$choice" in
    " Limpiar caché de paquetes")
        bash "$DIR/clean_cache.sh"
        show_message " Advertencia" "✔ Caché de paquetes se ha limpiado con éxito." 5
        ;;
    " Eliminar paquetes huérfanos")
        bash "$DIR/clean_orphans.sh"
        show_message " Advertencia" "✔ Paquetes huérfanos eliminados con éxito." 5
        ;;

    " Ver servicios en ejecución")
        alacritty -t sys_services -e bash -c "$DIR/check_services.sh; exec bash" &
        ;;
        
    " Procesos pesados")
        alacritty -t kill-c -e bash -c "$DIR/kill_heavy.sh; read -p 'Presiona Enter para cerrar...'" &
                ;;

    " Estado RAM/Swap")
        RAM_INFO=$(bash "$DIR/ram_swap.sh")
        show_message1 " Advertencia" "$RAM_INFO" 5
        ;;
    *)
        exit 0
        ;;
esac
