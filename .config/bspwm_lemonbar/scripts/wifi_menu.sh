#!/bin/bash
#######################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/wifi_menu.sh
# Descripción: Menú interactivo Wi-Fi con Rofi.
#              Permite:
#                - Conectar redes guardadas o nuevas (pidiendo
#                  contraseña si es necesario)
#                - Desconectar la red activa
#                - Olvidar redes guardadas
#              Las redes se organizan en filas:
#                1ª fila: red actualmente conectada
#                2ª-n fila: redes guardadas pero no conectadas
#                últimas filas: redes nunca conectadas antes
#              Se usan 3 columnas con ancho fijo:
#                1) Nombre de red (30 caracteres)
#                2) Olvidar (si aplica)
#                3) Conectar/Desconectar
# Autor: Yandri Loor
# Última modificación: 20 de Septiembre del 2025
#######################################################

ROFI_CMD="rofi -dmenu -i  -theme ~/.config/rofi/wifi.rasi"

# Ancho fijo para la columna del nombre de red
NAME_WIDTH=20

# ----------------------------
# 1) Red actualmente conectada
# ----------------------------
ACTIVE_SSID=$(nmcli -t -f NAME,DEVICE connection show --active | awk -F: '$2!="" {print $1; exit}')

# ----------------------------
# 2) Redes visibles
# ----------------------------
mapfile -t VISIBLE_SSIDS < <(nmcli -t -f SSID dev wifi | sort -u)

# ----------------------------
# 3) Redes guardadas
# ----------------------------
mapfile -t SAVED_SSIDS < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="802-11-wireless"{print $1}')

# ----------------------------
# Construir menú dinámico
# ----------------------------
MENU=""
declare -A ACTIONS

# Primera fila: red activa
if [ -n "$ACTIVE_SSID" ]; then
    NAME_COL=$(printf "%-${NAME_WIDTH}s" "$ACTIVE_SSID")
    MENU+="$NAME_COL [󰆴 Olvidar] [󰍛 Desconectar]\n"
    ACTIONS["$NAME_COL [󰆴 Olvidar]"]="forget"
    ACTIONS["$NAME_COL [󰍛 Desconectar]"]="disconnect"
fi

# Redes guardadas (no activas)
for ssid in "${SAVED_SSIDS[@]}"; do
    [ "$ssid" = "$ACTIVE_SSID" ] && continue
    if printf '%s\n' "${VISIBLE_SSIDS[@]}" | grep -qx "$ssid"; then
        NAME_COL=$(printf "%-${NAME_WIDTH}s" "$ssid")
        MENU+="$NAME_COL [󰆴 Olvidar] [ 󰈀  Conectar ]\n"
        ACTIONS["$NAME_COL [󰆴 Olvidar]"]="forget"
        ACTIONS["$NAME_COL [ 󰈀  Conectar ]"]="connect"
    fi
done

# Redes nunca conectadas
for ssid in "${VISIBLE_SSIDS[@]}"; do
    [[ "$ssid" = "$ACTIVE_SSID" ]] && continue
    [[ " ${SAVED_SSIDS[*]} " == *" $ssid "* ]] && continue
    NAME_COL=$(printf "%-${NAME_WIDTH}s" "$ssid")
    MENU+="$NAME_COL             [ 󱘖  Conectar ]\n"
    ACTIONS["$NAME_COL [ 󱘖  Conectar ]"]="connect"
done

# ----------------------------
# Mostrar menú en Rofi
# ----------------------------
CHOICE=$(echo -e "$MENU" | $ROFI_CMD)

[ -z "$CHOICE" ] && exit 0

# ----------------------------
# Determinar acción
# ----------------------------
COLUMN=$(echo "$CHOICE" | awk '{print $2}')

if [[ "$COLUMN" == "[󰆴" ]]; then
    SSID=$(echo "$CHOICE" | awk '{print $1}')
    ACTION="forget"
elif [[ "$COLUMN" == "[󰍛" || "$COLUMN" == "[󰈀" || "$COLUMN" == "[󱘖" ]]; then
    SSID=$(echo "$CHOICE" | awk '{print $1}')
    ACTION="connect_disconnect"
else
    exit 0
fi

# ----------------------------
# Ejecutar acción
# ----------------------------
case "$ACTION" in
    forget)
        nmcli connection delete "$SSID" && notify-send " Olvidada" "Red: $SSID"
        ;;
    connect_disconnect)
        if [ "$SSID" = "$ACTIVE_SSID" ]; then
            nmcli connection down "$SSID" && notify-send " Desconectada" "Red: $SSID"
        else
            if nmcli connection show | grep -q "^$SSID$"; then
                nmcli connection up "$SSID" && notify-send " Conectado" "A la red: $SSID"
            else
                PASS=$(rofi -dmenu -password -p "Contraseña $SSID:")
                [ -n "$PASS" ] && nmcli dev wifi connect "$SSID" password "$PASS" \
                    && notify-send " Conectado" "A la red: $SSID"
            fi
        fi
        ;;
esac

