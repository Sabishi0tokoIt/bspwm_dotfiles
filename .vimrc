"==============================================================
" Archivo: ~/.vimrc
" Descripción: Configuración de Vim con tema Eclipse oscuro,
"              números de línea, indentación de 4 espacios,
"              y soporte de copiar/pegar con el portapapeles.
" Autor: Yandri Loor
" Última modificación: 22 de Septiembre del 2025
"==============================================================

" ==========================
" Tema Eclipse Oscuro
" ==========================
if has("termguicolors")
  set termguicolors
endif
colorscheme elflord      " Eclipse-like theme

" ==========================
" Números de línea
" ==========================
set number               " Muestra números de línea
set ruler                " Muestra posición del cursor

" ==========================
" Indentación
" ==========================
set softtabstop=3        " Cada tab es 4 espacios
set shiftwidth=3         " Indentación automática de 4 espacios
set expandtab            " Convierte tabs en espacios
set smartindent          " Indentación inteligente
set smarttab

" ==========================
" Copiado y pegado
" ==========================
set clipboard=unnamedplus " Usa el portapapeles del sistema

" ==========================
" Otras mejoras
" ==========================
syntax on                " Resalta sintaxis
set background=dark      " Fondo oscuro
set incsearch            " Resalta búsqueda incremental
set hlsearch             " Resalta búsqueda completa
set scrolloff=5          " Mantener 5 líneas por arriba/abajo
set mouse=a              " Habilita mouse (scroll/clic)
" Tamaño de la ventana en columnas y filas
set lines=40
set columns=100

" ====================
" Tamaños en píxeles 
" ====================
if has("gui_running")
    set lines=24 columns=93
endif

