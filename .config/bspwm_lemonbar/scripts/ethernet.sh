#!/bin/bash
####################################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/ethernet.sh
# Descripción:
#   Script para mostrar información de la red Ethernet (cableada)
#   mediante notificación. Se ejecuta con un clic izquierdo en el icono
#   de red dentro de la barra.
#
# Funcionamiento:
#   - Detecta la interfaz de red cableada activa.
#   - Muestra información básica: nombre de interfaz, estado, IP,
#     dirección MAC y velocidad del enlace.
#   - Usa notify-send para notificación rápida.
#   - Iconos y colores se toman del archivo config.
#
# Autor: Yandri Loor
# Última modificación: 21 de Septiembre del 2025
####################################################################

# Cargar variables de iconos y colores desde config
source ~/.config/bspwm_lemonbar/config

# Detectar la primera interfaz Ethernet activa
INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^e' | head -n 1)

# Verificar si hay interfaz Ethernet
if [ -z "$INTERFACE" ]; then
    notify-send "$ICON_ETH" "No se detectó interfaz Ethernet"
    exit 1
fi

# Obtener datos de la interfaz
STATE=$(cat /sys/class/net/"$INTERFACE"/operstate 2>/dev/null)
IP=$(ip -4 addr show "$INTERFACE" | awk '/inet / {print $2}' | cut -d/ -f1)
MAC=$(cat /sys/class/net/"$INTERFACE"/address 2>/dev/null)
SPEED=$(cat /sys/class/net/"$INTERFACE"/speed 2>/dev/null || echo "Desconocida")

# Si no tiene IP asignada
if [ -z "$IP" ]; then
    IP="Sin asignar"
fi

# Construir mensaje con iconos desde config
MESSAGE="\n$ICON_ETH Interfaz: $INTERFACE
$ICON_STATE Estado: $STATE
$ICON_IP IP: $IP
$ICON_BSSID MAC: $MAC
$ICON_SPEED Velocidad: ${SPEED}Mb/s"

# Mostrar notificación
notify-send "   $ICON_ETH Conexión Ethernet" "$MESSAGE"

