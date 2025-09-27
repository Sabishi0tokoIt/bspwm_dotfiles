#!/bin/bash
###############################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/power_menu.sh# Descripción: 
#   Menú de apagado estilo LightDM con confirmación.
#   Opciones: Apagar, Reiniciar, Suspender, Bloquear, Cancelar.
#   Usa rofi y systemctl/loginctl.
# Autor: Yandri Loor
# Fecha de cración: 25 de Septiembre del 2025
# Última modificación: 25 de Septiembre del 2025
###############################################################
#!/bin/bash
ROFI_CMD="rofi -dmenu -i -theme ~/.config/rofi/power_menu.rasi"

options=(
    "⏻ Apagar"
    " Reiniciar"
    " Suspender"
    " Bloquear"
    "󰅖 Cancelar"
)

choice=$(printf '%s\n' "${options[@]}" | $ROFI_CMD -p "Sistema")

[ -z "$choice" ] || [ "$choice" = "󰅖 Cancelar" ] && exit 0

confirm=$(printf "Sí\nNo" | $ROFI_CMD -p "¿Seguro que deseas $choice?")

[ "$confirm" != "Sí" ] && exit 0

case "$choice" in
    "⏻ Apagar") systemctl poweroff ;;
    " Reiniciar") systemctl reboot ;;
    " Suspender") systemctl suspend ;;
    " Bloquear") loginctl lock-session ;;
esac

