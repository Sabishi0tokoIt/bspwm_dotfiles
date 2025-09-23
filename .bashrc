#######################################################
# Archivo: ~/.bashrc
# Descripción: Configuración de historial tipo tcsh en Bash.
#              Permite recorrer comandos que comienzan con
#              lo que ya has escrito usando ↑ y ↓.
# Autor: Yandri Loor
# Última modificación: 22 de Septiembre del 2025
#######################################################

# Activar búsqueda incremental en historial
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Explicación:
# "\e[A" = tecla ↑
# "\e[B" = tecla ↓
# history-search-backward/forward = busca comandos que empiezan con lo escrito

