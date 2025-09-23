#!/bin/bash
###########################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/sys_maintenance/kill_heavy.sh 
# Descripción: Muestra procesos que más consumen memoria/CPU,
#              con opción de terminarlos.
# Autor: Yandri Loor
# Última modificación: 21 de Septiembre 2025
###########################################################

echo ">>> Procesos que más memoria consumen:"
ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 15

read -p "¿Quieres matar algún proceso? (PID o Enter para omitir): " pid
if [[ -n "$pid" ]]; then
    kill -9 "$pid" && echo "✔ Proceso $pid terminado." || echo "⚠ No se pudo terminar el proceso."
fi

