#######################################################
# Archivo: ~/.bashrc
# Descripción: Configuración personalizada de Bash
# Autor: Yandri Loor
# Última modificación: 27 de Septiembre del 2025
#######################################################

### HISTORIAL TIPO TCSH ###
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

### COLORES Y COMPLETION ###
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
if [[ $- == *i* ]] && [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

eval "$(dircolors -b ~/.dircolors)"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

### HISTORIAL EXTENDIDO ###
shopt -s histappend
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000
PROMPT_COMMAND='history -a; history -n'

### ALIASES ###
# Navegación
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Listados con eza
alias ls='eza --icons --color=auto --group-directories-first'
alias ll='eza -lh --icons --group-directories-first'
alias la='eza -lAh --icons --group-directories-first'
alias l='eza -CF --icons --group-directories-first'

# Seguridad
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

### PROMPT ###
# Soporte Git
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    . /usr/share/git/completion/git-prompt.sh
fi

# Prompt dinámico según usuario (verde normal, rojo root)
if [ "$EUID" -eq 0 ]; then
    PS_COLOR="\[\e[1;31m\]"   # rojo
    PROMPT_CHAR="#"
else
    PS_COLOR="\[\e[1;32m\]"   # verde
    PROMPT_CHAR="$"
fi

PS1="${PS_COLOR}\u@\h \[\e[1;34m\]\w\[\e[33m\]\[\e[0m\] ${PROMPT_CHAR} "
#PS1="${PS_COLOR}\u@\h \[\e[1;34m\]\w\[\e[33m\]$(__git_ps1)\[\e[0m\] ${PROMPT_CHAR} "

