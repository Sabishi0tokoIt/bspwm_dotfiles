#!/bin/bash
###############################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/desktop.sh
# Descripción: Cambia al escritorio que recibe como argumento (1-based desde lemonbar)
# Autor: Yandri Loor
# Fecha: 22 de Septiembre de 2025
###############################################################

CMD="$1"  # recibimos "DESK_CHANGE 2"

# Extraer solo el número/nombre del escritorio
DESK="${CMD#DESK_CHANGE }"

# Obtener la lista actual de escritorios
mapfile -t DESKTOPS < <(bspc query -D --names)

# Verificar que exista
if [[ " ${DESKTOPS[*]} " =~ " $DESK " ]]; then
    bspc desktop "$DESK" -f
else
    echo "DEBUG: escritorio inválido: $DESK" >&2
    echo "DEBUG: escritorios actuales -> ${DESKTOPS[*]}" >&2
fi
