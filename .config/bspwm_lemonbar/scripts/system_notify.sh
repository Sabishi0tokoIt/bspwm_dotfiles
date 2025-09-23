#!/bin/bash
####################################################################
# Archivo:  ~/.config/bspwm_lemonbar/scripts/system_notify.sh
# Descripción:
#   Script para mostrar información completa del sistema:
#   CPU, frecuencia, temperatura, memoria, swap, disco y carga promedio.
#   Cada valor tiene su icono.
# Autor: Yandri Loor
# Última modificación: 21 de Septiembre del 2025
####################################################################

# Cargar iconos desde config
source ~/.config/bspwm_lemonbar/config

# -------------------
# CPU (uso ligero)
# -------------------
CPU_USAGE=$(awk -v prev_total=0 -v prev_idle=0 '
BEGIN{
    getline < "/proc/stat"
    split($0, a)
    idle = a[5]; total = 0
    for(i=2;i<=NF;i++) total += a[i]
    usage = (total - prev_total - (idle - prev_idle)) / (total - prev_total) * 100
    print usage
}')

CPU_ICON="$ICON_CPU"

# -------------------
# Frecuencia CPU
# -------------------
CPU_FREQ=$(awk -F: '/cpu MHz/ {sum+=$2; n++} END {if(n>0) printf "%.0f MHz", sum/n; else print "N/A"}' /proc/cpuinfo)
FREQ_ICON="$ICON_FRECUENCY"

# -------------------
# Temperatura CPU
# -------------------
CPU_TEMP="N/A"
TEMP_ICON="$ICON_TEMP"
if command -v sensors >/dev/null 2>&1; then
    CPU_TEMP=$(sensors | awk '/^Package id 0:/ {print $4}' | tr -d '+°C')
    [ -z "$CPU_TEMP" ] && CPU_TEMP="N/A"
fi

# -------------------
# Memoria RAM
# -------------------
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_USAGE=$(( MEM_USED * 100 / MEM_TOTAL ))
MEM_ICON="$ICON_MEMORY"

# -------------------
# Swap
# -------------------
SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')

if [[ "$SWAP_USAGE" =~ ^[0-9]+$ ]]; then
    if [ "$SWAP_USAGE" -ge 80 ]; then
        COLOR="$WARNING"
    elif [ "$SWAP_USAGE" -ge 50 ]; then
        COLOR="$CCPUM"
    else
        COLOR="$CCPUB"
    fi
else
    COLOR="$CCPUB"  # Valor por defecto si SWAP_USAGE no es número
fi


SWAP_ICON="$ICON_SWAP"


# -------------------
# Disco raíz
# -------------------
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_ICON="$ICON_DISK"

# -------------------
# Carga promedio
# -------------------
LOAD=$(uptime | awk -F'load average:' '{print $2}' | xargs)
LOAD_ICON="$ICON_LOAD"

# -------------------
# Construir mensaje
# -------------------
MESSAGE="$CPU_ICON CPU: ${CPU_USAGE}%
$FREQ_ICON Frecuencia: ${CPU_FREQ}
$TEMP_ICON Temperatura: ${CPU_TEMP}°C
$MEM_ICON Memoria: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_USAGE}%)
$SWAP_ICON Swap: ${SWAP_USED}MB / ${SWAP_TOTAL}MB (${SWAP_USAGE}%)
$DISK_ICON Disco: ${DISK_USED} / ${DISK_TOTAL}
$LOAD_ICON Carga: $LOAD"

# -------------------
# Mostrar notificación
# -------------------
notify-send "$ICON_SYSTEM Estado del Sistema" "$MESSAGE"

