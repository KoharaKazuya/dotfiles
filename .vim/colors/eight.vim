set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name="eight"

" color terminal definitions
" hi SpecialKey    ctermfg=darkgreen
" hi NonText       cterm=bold ctermfg=darkblue
" hi Directory     ctermfg=darkcyan
" hi ErrorMsg      cterm=bold ctermfg=7 ctermbg=1
hi IncSearch     cterm=NONE ctermfg=0 ctermbg=3
hi Search        cterm=NONE ctermfg=0 ctermbg=3
" hi MoreMsg       ctermfg=darkgreen
" hi ModeMsg       cterm=NONE ctermfg=brown
hi LineNr        ctermfg=7 ctermbg=0
" hi Question      ctermfg=green
" hi StatusLine    cterm=bold,reverse
" hi StatusLineNC  cterm=reverse
" hi VertSplit     cterm=reverse
" hi Title         ctermfg=5
hi Visual        ctermbg=0
" hi VisualNOS     cterm=bold,underline
" hi WarningMsg    ctermfg=1
" hi WildMenu      ctermfg=0 ctermbg=3
" hi Folded        ctermfg=darkgrey ctermbg=NONE
" hi FoldColumn    ctermfg=darkgrey ctermbg=NONE
" hi DiffAdd       ctermbg=4
" hi DiffChange    ctermbg=5
" hi DiffDelete    cterm=bold ctermfg=4 ctermbg=6
" hi DiffText      cterm=bold ctermbg=1
hi Comment       ctermfg=0
hi Constant      ctermfg=1
hi Special       cterm=bold ctermfg=1
hi Identifier    ctermfg=4
hi Statement     ctermfg=3
hi PreProc       ctermfg=5
hi Type          ctermfg=2
hi Underlined    cterm=underline
hi Ignore        ctermfg=0
hi Error         cterm=bold ctermfg=7 ctermbg=1
