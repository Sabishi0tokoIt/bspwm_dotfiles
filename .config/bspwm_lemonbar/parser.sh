#!/bin/bash
####################################################################
# Archivo: ~/.config/bspwm_lemonbar/parser.sh
# Descripción: Script de integración entre BSPWM y LemonBar.
#              Procesa y formatea la información del sistema para LemonBar,
#              incluyendo:
#              - Datos de BSPWM: Desktops, ventanas activas, títulos de ventanas.
#              - Módulos del sistema: Hora/fecha, volumen, batería, estado de red.
#              - Formato de salida: Añade colores, iconos y separadores para LemonBar.
#              - Lógica de actualización: Gestiona la frecuencia y eventos de actualización.
#              - Personalización: Permite añadir o modificar módulos según necesidades.
# Autor: Yandri Loor
# Fecha de cración: 19 de Septiembre del 2025
# Última modificación: 25 de Septiembre del 2025
####################################################################

CONFIG="$HOME/.config/bspwm_lemonbar/config"
[ -f "$CONFIG" ] && source "$CONFIG"
#CLICK_ACTIONS="$HOME/.config/bspwm_lemonbar/config"
#[ -f "$CLICK_ACTIONS" ] && source "$CLICK_ACTIONS"

##############
# Escritorios
############## 
W() { 
    # Obtener lista de escritorios 
    DESKTOPS=($(bspc query -D --names)) 

    # Obtener el escritorio activo 
    ACTIVE_DESKTOP=$(bspc query -D -d focused --names) 

    # Mostrar iconos de los escritorios 
    for i in "${!DESKTOPS[@]}"; do 
        ICON="${DESKTOP_ICONS[$i]:-"?"}" 
        DESK="${DESKTOPS[$i]}"

        if [ "$DESK" = "$ACTIVE_DESKTOP" ]; then 
            echo -n "%{F$ACTIVE}%{A1:DESK_CHANGE_$DESK:}$ICON %{A}" 
        else 
            echo -n "%{F$INACTIVE}%{A1:DESK_CHANGE_$DESK:}$ICON %{A}" 
        fi
    done
}



##########################
# Títulos de las ventanas
##########################

WT(){
	# Obtener ventana activa
	local title
	title=$(xtitle "$(xprop -root _NET_ACTIVE_WINDOW |awk '{print $5}')" 2>/dev/null)
	
	# Si está activo, mostrar algo por defecto
	if [ -z "$title" ]; then
		title="Ninguna ventana activa"
	fi

	# Recortar si es demasiado largo
	echo "%{F$FG}$title%{F-}"
}

###########
# BATERÍA
###########

BAT() {
    # Ubicación de la batería (ajusta según tu sistema)
    BAT_PATH="/sys/class/power_supply/BAT1"

    # Nivel de batería en porcentaje
    if [ -f "$BAT_PATH/capacity" ]; then
        level=$(cat "$BAT_PATH/capacity")
    else
        level=0
    fi

    # Estado de carga
    charging=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo 0)

    # Selección de icono según nivel de batería
    if [ "$charging" -eq 1 ]; then
        icon_bat=${BATTERY_FULL}   # Puedes usar otro icono si quieres
        bat_color=$CBATC
    elif [ "$level" -ge 95 ]; then
        icon_bat=${BATTERY_FULL}
        bat_color=$CBATA
    elif [ "$level" -ge 75 ]; then
        icon_bat=${BATTERY_75}
        bat_color=$CBATM
    elif [ "$level" -ge 50 ]; then
        icon_bat=${BATTERY_50}
        bat_color=$CBATM
    elif [ "$level" -ge 25 ]; then
        icon_bat=${BATTERY_25}
        bat_color=$CBATB
    else
        icon_bat=${BATTERY_0}
        bat_color=$CBATB
    fi

    # Alerta crítica por batería baja (<10%)
    if [ "$level" -le 10 ] && [ "$charging" -ne 1 ]; then
        bat_color=$WARNING
        icon_bat=$(BATTERY_0)
        notify-send -u critical "BATERÍA CRÍTICA" "Por favor conecta el adaptador"
    fi

    # Formato para lemonbar
    echo "%{F${bat_color}}${icon_bat} ${level}% %{F-}"
}

###########
# Volúmen
##########

VOL() {
    # Obtener volumen y estado de mute
    if command -v pamixer &>/dev/null; then
        vol=$(pamixer --get-volume)
        mute=$(pamixer --get-mute)
    else
        vol=$(amixer get Master | grep -oP '\[\d+%\]' | head -1 | tr -d '[]%')
        mute=$(amixer get Master | grep -o '\[off\]' | head -1)
        [ -n "$mute" ] && mute="true" || mute="false"
    fi

    # Selección de icono y color
    if [ "$mute" = "true" ]; then
        icon_vol=$VOL_MUTE
        vol_color=$WARNING
    elif [ "$vol" -ge 70 ]; then
        icon_vol=$VOL_HIGT
        vol_color=$CVOLA
    elif [ "$vol" -ge 30 ]; then
        icon_vol=$VOL_MEDIUM
        vol_color=$CVOLM
    elif [ "$vol" -gt 0 ]; then
        icon_vol=$VOL_LOW
        vol_color=$CVOLB
    else
        icon_vol=$VOL_MUTE
        vol_color=$WARNING
    fi

    # Salida formateada para lemonbar
    echo "%{F${vol_color}}${icon_vol} ${vol}% %{F-}"
}

###########
# Bluetooth
###########

BT() {
    # Ver si el adaptador está encendido
    POWERED=$(bluetoothctl show | awk -F': ' '/Powered:/ {print $2; exit}')

    if [ "$POWERED" = "yes" ]; then
        COLOR="$CBTA"             # Color activo desde config
        DEVICE=$(bluetoothctl info | awk -F': ' '/Name:/ {print $2; exit}')
        [ -z "$DEVICE" ] && DEVICE="Ninguno"
        STATUS="$DEVICE"
    else
        COLOR="$INACTIVE"         # Color inactivo desde config
        STATUS="INACTIVE"
    fi

    # Salida a Lemonbar con clics
    # A1: clic izquierdo → menú, A3: clic derecho → notificación
    echo "%{F$COLOR}%{A3:BLUETOOTH_NOTIFY:}%{A1:BLUETOOTH_MENU:}${ICON_BLUETOOTH}%{A}%{A}%{F-}"
}

########
# WIFI
########

WIFI() {
    # Obtiene la red activa y su señal
    ACTIVE_LINE=$(nmcli -t -f active,ssid,signal dev wifi | awk -F: '/^sí/ {print $0}')
    
    if [ -z "$ACTIVE_LINE" ]; then
        # No hay conexión
        COLOR="$WARNING"
        SSID="Desconocida"
        SIGNAL="0"
    else
        SSID=$(echo "$ACTIVE_LINE" | cut -d: -f2)
        SIGNAL=$(echo "$ACTIVE_LINE" | cut -d: -f3)
        
        # Determinar color según la señal
        if [ "$SIGNAL" -ge 70 ]; then
            COLOR="$CWIFIA"   # Alta
        elif [ "$SIGNAL" -ge 40 ]; then
            COLOR="$CWIFIM"   # Media
        else
            COLOR="$CWIFID"   # Débil
        fi
    fi

    # Salida a lemonbar con clic izquierdo y derecho
    # Formato: icono + SSID + porcentaje
    echo "%{F$COLOR}%{A3:WIFI_NOTIFY:}%{A1:WIFI_MENU:}${ICON_WIFI} %{A}%{A}%{F-}"
}

###########
# Ethernet
###########

ETH() {
    # Detectar interfaz Ethernet activa (primera que esté UP)
    INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^e' | head -n 1)

    # Si no hay interfaz o está inactiva, no mostrar nada
    if [ -z "$INTERFACE" ] || [ "$(cat /sys/class/net/$INTERFACE/operstate 2>/dev/null)" != "up" ]; then
        echo ""  # No imprime nada
        return
    fi

    # Estado de la interfaz
    STATE=$(cat /sys/class/net/"$INTERFACE"/operstate 2>/dev/null)
    SPEED=$(cat /sys/class/net/"$INTERFACE"/speed 2>/dev/null || echo "Desconocida")

    # Determinar color según el estado
    if [ "$STATE" = "up" ]; then
        COLOR="$CWIFIA"   # Verde si activo
    else
        COLOR="$WARNING"  # Rojo si inactivo (no debería pasar)
    fi

    # Salida a lemonbar con clics
    # Formato: icono + interfaz + velocidad
    echo "%{F$COLOR}%{A3:ETH_NOTIFY:}%{A1:ETH_MENU:}${ICON_ETH}%{A}%{A}%{F-}"
}

##########################
# Sistema (resumen)
##########################

SYS() {
    # CPU Usage ligero
	CPU_USAGE=$(awk '
		{
		    idle=$5
		    total=0
		    for(i=2;i<=NF;i++) total+=$i
		    if (total==0) {usage=0} else {usage=100*(total-idle)/total}
	    	print usage
		}' /proc/stat | head -n1)
	CPU_USAGE_INT=${CPU_USAGE%.*}  # quita decimales

    # Memoria
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_USAGE=$(( MEM_USED * 100 / MEM_TOTAL ))

    # Color dinámico según uso
	if [ "$CPU_USAGE_INT" -ge 80 ] || [ "$MEM_USAGE" -ge 80 ]; then
		COLOR="$WARNING"
	elif [ "$CPU_USAGE_INT" -ge 50 ] || [ "$MEM_USAGE" -ge 50 ]; then
		COLOR="$CCPUM"
	else
		COLOR="$CCPUB"
	fi
	# Salida para Lemonbar con clic izquierdo para notificación completa
    echo "%{F$COLOR}%{A3:SYSTEM_NOTIFY:}%{A1:SYSTEM_MENU:}$ICON_SYSTEM%{F-}%{A}%{A}"
}

# #####
# Hora
# #####

TIME() {
    HORA=$(date +"%H:%M")
    echo "%{F$CHORA}$ICON_CLOCK$HORA%{F-}"
}

#########
# Fecha
#########

DATE() {
    FECHA=$(date +"%d/%m/%Y")
    echo "%{F$CDATE}$ICON_DATE $FECHA%{F-}"
}

######################
# Brillo de pantalla
######################

BRIGHT() {
    # Obtener brillo actual (0-100%)
    # Dependiendo del sistema, puede ser /sys/class/backlight/*/brightness
    # y max_brightness para normalizar
    BACKLIGHT_DIR=$(ls -d /sys/class/backlight/* | head -n1)
    if [ -d "$BACKLIGHT_DIR" ]; then
        CURRENT=$(cat "$BACKLIGHT_DIR/brightness")
        MAX=$(cat "$BACKLIGHT_DIR/max_brightness")
        BRIGHTNESS=$(( CURRENT * 100 / MAX ))
    else
        BRIGHTNESS=0
    fi

    # Color según nivel
    if [ "$BRIGHTNESS" -ge 75 ]; then
        COLOR="$CBRIA"  # Alto
    elif [ "$BRIGHTNESS" -ge 40 ]; then
        COLOR="$CBRIM"  # Medio
    else
        COLOR="$CBRIB"  # Bajo
    fi

    # Salida para Lemonbar (solo icono + porcentaje, sin clicable)
    echo "%{F$COLOR}$ICON_BRIGHT $BRIGHTNESS% %{F-}"
}

#############
# Power Menu
#############

POW() {
    # Botón de apagado con clic izquierdo
    echo "%{F$WARNING}%{A1:POWER_MENU:}$ICON_POWER%{A}%{F-}"
}


echo # salto de linea final
