#!/bin/bash
#######################################################
# Archivo: wifi_notify.sh
# Descripción: Notificación completa de Wi-Fi
#              usando iconos y colores desde config,
#              incluyendo SSID, BSSID, interfaz,
#              IP, estado, velocidad y señal.
# Autor: Yandri Loor
# Última modificación: 21 de Septiembre del 2025
#######################################################

# Cargar variables de iconos y colores desde config
source ~/.config/bspwm_lemonbar/config

# Detectar interfaz Wi-Fi activa
INTERFACE=$(nmcli -t -f DEVICE,TYPE,STATE dev | awk -F: '$2=="wifi" && $3=="connected"{print $1; exit}')

if [ -z "$INTERFACE" ]; then
    notify-send "$ICON_WIFI Wi-Fi" "No hay conexión Wi-Fi activa"
    exit 0
fi

# SSID
SSID=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="sí"{print $2; exit}')

# BSSID (MAC)
BSSID=$(iw dev "$INTERFACE" link | awk '/Connected to/ {print $3}')
BSSID=${BSSID:-N/A}

# Señal (dBm)
SIGNAL=$(iw dev "$INTERFACE" link | awk -F'signal: ' '/signal/ {print $2}' | awk '{print $1}')
SIGNAL=${SIGNAL:-N/A}

# Estado de la interfaz
STATE=$(cat /sys/class/net/"$INTERFACE"/operstate 2>/dev/null)

# Dirección IP
IP=$(ip -4 addr show "$INTERFACE" | awk '/inet /{print $2}' | cut -d/ -f1)

# Velocidad de enlace (tx bitrate)
SPEED=$(iw dev "$INTERFACE" link | awk -F'tx bitrate: ' '/tx bitrate/ {print $2}' | tr -d '\n')
SPEED=${SPEED:-N/A}

# Determinar color según intensidad de señal
if [ "$SIGNAL" = "N/A" ]; then
    COLOR="$WARNING"
elif [ "$SIGNAL" -ge 70 ]; then
    COLOR="$CWIFIA"
elif [ "$SIGNAL" -ge 40 ]; then
    COLOR="$CWIFIM"
else
    COLOR="$CWIFID"
fi

# Construir mensaje con iconos desde config
MESSAGE="\n$ICON_WIFI    SSID: ${SSID:-N/A}
$ICON_BSSID    BSSID: ${BSSID:-N/A}
$ICON_IP    IP: ${IP:-N/A}
$ICON_STATE    Estado: ${STATE:-N/A}
$ICON_SPEED    Velocidad: ${SPEED:-N/A}
$ICON_SIGNAL    Señal: ${SIGNAL:-N/A} dBm"

# Mostrar notificación con color
notify-send "       $ICON_WIFI  Conexión Wi-Fi" "$MESSAGE"

