#!/bin/bash
#######################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/wifi_menu.sh
# Descripción: Abre nm-connection-editor en modo flotante
#              y se cierra automáticamente si:
#                - Se cierra una ventana hija
#                - Pierde el foco
#                - No hay interacción durante 5 segundos
# Autor: Yandri Loor
# Última modificación: 24 de Septiembre del 2025
#######################################################

nm-connection-editor &
PID=$!

# Espera a que aparezca la ventana principal
sleep 1

# Función para listar todas las ventanas del proceso
get_windows() {
    xdotool search --pid "$PID" 2>/dev/null
}

# Forzar foco en la primera ventana
MAIN_WIN=$(get_windows | head -n1)
[ -n "$MAIN_WIN" ] && xdotool windowfocus "$MAIN_WIN"

# Variables de control
HAD_CHILD=0
LAST_INTERACTION=$(date +%s)   # tiempo de la última interacción
TIMEOUT=5                      # segundos sin interacción

while sleep 1; do
    CURR=$(xdotool getwindowfocus 2>/dev/null)
    WINS=$(get_windows)

    # Si el proceso ya terminó, salir
    [ -z "$WINS" ] && exit 0

    COUNT=$(echo "$WINS" | wc -l)

    # Registrar que hubo ventana hija
    if [ "$COUNT" -gt 1 ]; then
        HAD_CHILD=1
    fi

    # Si el foco está en alguna ventana del proceso → actualizar última interacción
    if echo "$WINS" | grep -q "$CURR"; then
        LAST_INTERACTION=$(date +%s)
    fi

    # Condición 1: se cerró la hija => cerrar todo
    if [ "$COUNT" -eq 1 ] && [ "$HAD_CHILD" -eq 1 ]; then
        for win in $WINS; do xdotool windowclose "$win" 2>/dev/null; done
        kill $PID 2>/dev/null
        break
    fi

    # Condición 2: perdió el foco => cerrar todo
    if ! echo "$WINS" | grep -q "$CURR"; then
        for win in $WINS; do xdotool windowclose "$win" 2>/dev/null; done
        kill $PID 2>/dev/null
        break
    fi

    # Condición 3: 5s sin interacción => cerrar todo
    NOW=$(date +%s)
    if (( NOW - LAST_INTERACTION >= TIMEOUT )); then
        for win in $WINS; do xdotool windowclose "$win" 2>/dev/null; done
        kill $PID 2>/dev/null
        break
    fi
done

