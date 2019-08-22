set encoding=utf-8  " 文字コードに UTF-8 を使用

" 表示設定
colorscheme eight
syntax on         " コードの色分け
set number        " 行番号表示
set ruler         " 右下に行、列番号を表示
set scrolloff=5   " スクロールの際に下が見えるように
set list          " 不可視文字を表示
set listchars=tab:»\ ,trail:-  " 不可視文字を設定
set expandtab     " ソフトタブ有効
set autoindent    " 改行時に前の行のインデントを継続する
set smartindent   " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set showcmd       " 入力途中のコマンドを表示する
set cursorline    " カーソルがある行を強調する
" 一行 80 文字以上は背景色を変える
highlight OverLength term=reverse ctermbg=238 guibg=DarkGrey
match OverLength /\%<120v.\%>81v/
" 全角スペースを強調表示する
highlight IdeographicSpace term=reverse ctermbg=238 guibg=DarkGrey
match IdeographicSpace /　/

" 検索設定
set incsearch   " インクリメンタルサーチを行う
set hlsearch    " 検索結果をハイライト

" 入力設定
if has('mouse')
  set mouse=a   " マウスモード有効
endif

" インデント設定
set tabstop=2
set shiftwidth=2

" Modeline を有効にする
set modeline
set modelines=5  " macOS ではデフォルトで modeline=0 となっているので上書き

" filetype プラグインを有効にする
filetype plugin on
