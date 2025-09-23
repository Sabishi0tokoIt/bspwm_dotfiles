#!/bin/bash
###########################################################
# Archivo: ~/.config/bspwm_lemonbar/scripts/sys_maintenance/clean_orphans.sh
# Descripción: Elimina dependencias huérfanas de pacman.
# Autor: Yandri Loor
# Última modificación: 22 de Septiembre 2025
###########################################################

orphans=$(pacman -Qtdq)

if [[ -z "$orphans" ]]; then
    echo "✔ No hay dependencias huérfanas."
else
    echo "⚠ Se encontraron dependencias huérfanas:"
    echo "$orphans"
    read -p "¿Quieres eliminarlas? [s/N]: " resp
    if [[ "$resp" =~ ^[sS]$ ]]; then
        sudo pacman -Rns $orphans
    fi
fi

