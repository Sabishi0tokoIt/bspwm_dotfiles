#!/bin/bash


# Cargar variables y configuraciones X
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Configurar teclado, ratón, etc. si es necesario
setxkbmap es

# Iniciar compositor (opcional)
#picom &

# Iniciar paneles/barra
~/.config/bspwm_lemonbar/bar.sh &

# Iniciar BSPWM
exec bspwm


