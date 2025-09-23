#!/bin/bash
#######################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/bluetooth_menu.sh
# Descripción: Menú interactivo de Bluetooth con Rofi
#              Funciona en Arch Linux moderno sin hciconfig
# Autor: Yandri Loor
# Última modificación: 23 de Septiembre del 2025
#######################################################

ROFI_CMD="rofi -dmenu -i -theme ~/.config/rofi/bluetooth.rasi"
NAME_WIDTH=20

# -----------------------
# Estado del adaptador
# -----------------------
POWERED=$(bluetoothctl show | awk -F': ' '/Powered:/ {print $2}')

MENU=""
declare -A ACTIONS

# Opción adaptador
NAME_COL=$(printf "%-${NAME_WIDTH}s" "Adaptador")
if [ "$POWERED" = "yes" ]; then
    MENU+="$NAME_COL [󰂯 Apagar]\n"
    ACTIONS["$NAME_COL [󰂯 Apagar]"]="power_off"
else
    MENU+="$NAME_COL [󰂯 Encender]\n"
    ACTIONS["$NAME_COL [󰂯 Encender]"]="power_on"
fi

# -----------------------
# Dispositivos emparejados
# -----------------------
mapfile -t PAIRED < <(bluetoothctl -- devices | awk '{print $2 " " substr($0, index($0,$3))}')

CONNECTED_DEV=""
OTHER_DEVICES=()

for dev in "${PAIRED[@]}"; do
    MAC=$(echo "$dev" | awk '{print $1}')
    NAME=$(echo "$dev" | cut -d' ' -f2-)

    CONNECTED=$(bluetoothctl info "$MAC" | awk -F': ' '/Connected:/ {print $2}')

    if [ "$CONNECTED" = "yes" ]; then
        CONNECTED_DEV="$dev"
    else
        OTHER_DEVICES+=("$dev")
    fi
done

# Dispositivo conectado primero
if [ -n "$CONNECTED_DEV" ]; then
    MAC=$(echo "$CONNECTED_DEV" | awk '{print $1}')
    NAME=$(echo "$CONNECTED_DEV" | cut -d' ' -f2-)
    NAME_COL=$(printf "%-${NAME_WIDTH}s" "$NAME")
    MENU+="$NAME_COL [󰍛 Desconectar] [󰆴 Olvidar]\n"
    ACTIONS["$NAME_COL [󰍛 Desconectar]"]="disconnect:$MAC"
    ACTIONS["$NAME_COL [󰆴 Olvidar]"]="remove:$MAC"
fi

# Otros dispositivos emparejados
for dev in "${OTHER_DEVICES[@]}"; do
    MAC=$(echo "$dev" | awk '{print $1}')
    NAME=$(echo "$dev" | cut -d' ' -f2-)
    NAME_COL=$(printf "%-${NAME_WIDTH}s" "$NAME")
    MENU+="$NAME_COL [󰈀 Conectar] [󰆴 Olvidar]\n"
    ACTIONS["$NAME_COL [󰈀 Conectar]"]="connect:$MAC"
    ACTIONS["$NAME_COL [󰆴 Olvidar]"]="remove:$MAC"
done

# -----------------------
# Escanear dispositivos disponibles
# -----------------------
if [ "$POWERED" = "yes" ]; then
    mapfile -t AVAILABLE < <(
        timeout 5s bash -c "echo -e 'scan on\nquit' | bluetoothctl 2>/dev/null" \
        | awk '/Device/ {print $2 " " substr($0, index($0,$3))}'
    )

    for dev in "${AVAILABLE[@]}"; do
        MAC=$(echo "$dev" | awk '{print $1}')
        NAME=$(echo "$dev" | cut -d' ' -f2-)

        # No mostrar si ya está emparejado
        if printf '%s\n' "${PAIRED[@]}" | grep -q "$MAC"; then
            continue
        fi

        NAME_COL=$(printf "%-${NAME_WIDTH}s" "$NAME")
        MENU+="$NAME_COL [󰈀 Conectar]\n"
        ACTIONS["$NAME_COL [󰈀 Conectar]"]="connect:$MAC"
    done
fi

# -----------------------
# Mostrar menú en Rofi
# -----------------------
CHOICE=$(echo -e "$MENU" | $ROFI_CMD)
[ -z "$CHOICE" ] && exit 0

# -----------------------
# Ejecutar acción
# -----------------------
ACTION=${ACTIONS["$CHOICE"]}
case "$ACTION" in
    power_on)
        bluetoothctl power on && notify-send "󰂯 Bluetooth" "Adaptador encendido"
        ;;
    power_off)
        bluetoothctl power off && notify-send "󰂯 Bluetooth" "Adaptador apagado"
        ;;
    connect:*)
        MAC=${ACTION#connect:}
        # Ver si ya está emparejado
        if bluetoothctl info "$MAC" | grep -q "Paired: yes"; then
            bluetoothctl connect "$MAC" && notify-send "󰂯 Conectado" "$MAC"
        else
            notify-send "󰂯 Emparejando..." "$MAC"
            echo -e "pair $MAC\nconnect $MAC\nquit" | bluetoothctl &>/dev/null
            if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
                notify-send "󰂯 Conectado" "$MAC"
            else
                notify-send "󰂯 Error al conectar" "$MAC"
            fi
        fi
        ;;
    disconnect:*)
        MAC=${ACTION#disconnect:}
        bluetoothctl disconnect "$MAC" && notify-send "󰂯 Desconectado" "$MAC"
        ;;
    remove:*)
        MAC=${ACTION#remove:}
        bluetoothctl remove "$MAC" && notify-send "󰂯 Eliminado" "$MAC"
        ;;
esac

