#!/bin/bash
###########################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/sys_maintenance/clean_cache.sh
# Descripción: Limpia la caché de pacman para liberar espacio.
# Autor: Yandri Loor
# Última modificación: 21 de Septiembre 2025
###########################################################

echo ">>> Espacio usado en /var/cache/pacman/pkg/:"
du -sh /var/cache/pacman/pkg/

read -p "¿Quieres limpiar la caché (mantener última versión)? [s/N]: " resp
if [[ "$resp" =~ ^[sS]$ ]]; then
    sudo pacman -Sc
fi

