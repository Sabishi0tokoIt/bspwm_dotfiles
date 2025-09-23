#!/bin/bash
#######################################################
# Archivo: bluetooth_notify.sh
# Descripción: Notificación completa de Bluetooth
#              usando iconos y colores desde config.
#              Muestra:
#                - Adaptador
#                - Estado (encendido/apagado)
#                - Dispositivo conectado
#                - Dirección MAC
# Autor: Yandri Loor
# Última modificación: 23 de Septiembre del 2025
#######################################################

# Cargar variables de iconos y colores desde config
source ~/.config/bspwm_lemonbar/config

# Adaptador
ADAPTER=$(bluetoothctl show | awk -F': ' '/Name:/ {print $2; exit}')
POWERED=$(bluetoothctl show | awk -F': ' '/Powered:/ {print $2; exit}')

if [ "$POWERED" != "yes" ]; then
    notify-send "$ICON_BLUETOOTH Bluetooth" "Adaptador apagado"
    exit 0
fi

# Dispositivo conectado
DEVICE=$(bluetoothctl info | awk -F': ' '/Name:/ {print $2; exit}')
MAC=$(bluetoothctl info | awk -F': ' '/Device/ {print $2; exit}')

if [ -z "$DEVICE" ]; then
    DEVICE="Ninguno"
    MAC="N/A"
fi

# Construir mensaje
MESSAGE="\n$ICON_ADAPTER   Adaptador: ${ADAPTER:-N/A}
$ICON_STATE     Estado: Encendido
$ICON_DEVICE    Dispositivo: $DEVICE
$ICON_MAC       MAC: $MAC"

notify-send "       $ICON_BLUETOOTH  Bluetooth" "$MESSAGE"

