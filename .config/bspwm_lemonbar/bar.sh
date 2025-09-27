#!/bin/bash
####################################################################
# Archivo: ~/.config/bspwm_lemonbar/bar.sh
# Descripción: Script principal para iniciar y gestionar LemonBar.
#              Responsabilidades:
#              - Iniciar LemonBar con los parámetros definidos en 'config'.
#              - Ejecutar 'parser.sh' para procesar y mostrar la información dinámica.
#              - Gestionar la persistencia de la barra (ej: reinicio automático en caso de fallo).
#              - Centralizar la integración entre BSPWM, LemonBar y los módulos del sistema.
# Autor: Yandri Loor
# Fecha de cración: 19 de Septiembre del 2025
# Última modificación: 19 de Septiembre del 2025
####################################################################

set -u

# Obtener la configuración de aspecto
CONFIG="$HOME/.config/bspwm_lemonbar/config"

if [ ! -f "$CONFIG" ]; then
	echo "La configuración no ha sido encontrada: $CONFIG" >&2
	exit 1
fi

PARSER="$HOME/.config/bspwm_lemonbar/parser.sh"

if [ ! -f "$PARSER" ]; then
	echo "El archivo parser no ha sido encontrado: $PARSER" >&2
	exit 1
fi


# Sourcear config
[ -f "$CONFIG" ] && source "$CONFIG"
[ -f "$PARSER" ] && source "$PARSER"

# Asegurar que variables tengan valor por defecto si faltan, ${VAR:-default}
##BG=${BG:-"#000000"}
#FG=${FG:-"#ffffff"}
#FONT_RAW=${FONT:-"JetBrains Mono-10"}
#FONT_ICON=${ICON_FONT:-"FiraCode Nerd Font-14"}
#BAR_HEIGHT=${BAR_HEIGHT:-20}
#BAR_WIDTH=${BAR_WIDTH:-1920}
#BAR_POSX=${BAR_POSX:-0}
#BAR_POSY=${BAR_POSY:-0}

# Bucle principal, que obtiene los datos de parser

while true; do
    # %{l} = izquierda, %{c} = centro, %{r} = derecha
    echo "%{l}$(W) %{c} $(WT) %{r} $(ETH) $(WIFI) $(BAT) $(BT) $(VOL) $(BRIGHT) $(SYS) $(DATE) $(TIME) $(POW)  "
    sleep 1

# Lanzar lemonbar.

done | lemonbar \
    -p \
    -g "${BAR_WIDTH}x${BAR_HEIGHT}+${BAR_POSX}+${BAR_POSY}" \
    -B "$BG" -F "$FG" \
    -f "$FONT" \
    -f "$ICON_FONT" | ~/.config/bspwm_lemonbar/scripts/click_handler.sh &




