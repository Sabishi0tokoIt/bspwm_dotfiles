#!/bin/bash
###########################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/sys_maintenance/check_services.sh
# Descripción: Lista servicios habilitados al inicio con systemd.
# Autor: Yandri Loor
# Última modificación: 21 de Septiembre 2025
###########################################################

echo ">>> Servicios habilitados en el arranque:"
systemctl list-unit-files --type=service | grep enabled

echo -e "\n👉 Para deshabilitar alguno:"
echo "   sudo systemctl disable nombre.service"
echo "👉 Para detenerlo ahora mismo:"
echo "   sudo systemctl stop nombre.service"
echo "   Cuando termines escribe 'exit' o presiona Ctrl+D."

bash
