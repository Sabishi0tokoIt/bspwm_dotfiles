#!/bin/bash
#######################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/bluetooth_menu.sh
# Descripción: Menú interactivo de Bluetooth con Rofi
#              Funciona en Arch Linux moderno sin hciconfig
# Autor: Yandri Loor
# Última modificación: 23 de Septiembre del 2025
#######################################################

# Si el applet no está corriendo, lo iniciamos en segundo plano
if ! pgrep -x "blueman-applet" > /dev/null; then
    blueman-applet &
fi

# Abrir el administrador gráfico
blueman-manager
