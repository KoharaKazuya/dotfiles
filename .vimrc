" 表示設定
colorscheme desert
syntax on         " コードの色分け
set tabstop=2     " インデントの表示をスペース２つ分に
set shiftwidth=2  " インデントの挿入をスペース２つ分に
set cindent       " オートインデント (C Language Style)
set number        " 行番号表示
set ruler         " 右下に行、列番号を表示
set scrolloff=5   " スクロールの際に下が見えるように
set list          " 不可視文字を表示
set listchars=tab:»\ ,trail:-  " 不可視文字を設定

" 検索設定
set incsearch   " インクリメンタルサーチを行う
set hlsearch    " 検索結果をハイライト

" 入力設定
if has('mouse')
  set mouse=a   " マウスモード有効
endif
set expandtab   " ソフトタブ有効
