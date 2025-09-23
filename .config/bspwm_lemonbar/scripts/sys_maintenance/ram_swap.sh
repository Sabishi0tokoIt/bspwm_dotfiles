#!/bin/bash
###########################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/sys_maintenance/ram_swap.sh
# Descripción: Muestra el uso de RAM y Swap.
# Autor: Yandri Loor
# Última modificación: 23 de Septiembre 2025
###########################################################

echo ">>> Uso de memoria RAM y Swap:"
free -h
echo
echo ">>> Procesos más pesados por memoria:"
ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 10

