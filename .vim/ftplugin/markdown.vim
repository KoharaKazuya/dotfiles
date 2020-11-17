" @see http://superbrothers.hatenablog.com/entry/2013/09/12/230608
syn match MkdCheckboxCancel /-\s\[\s\]\s\~\~.*\~\~/ display containedin=ALL
hi MkdCheckboxCancel ctermfg=darkgray
syn match MkdCheckboxMark /-\s\[x\]/ display containedin=ALL
hi MkdCheckboxMark ctermfg=green
syn match MkdCheckboxUnmark /-\s\[\s\]/ display containedin=ALL
hi MkdCheckboxUnmark ctermfg=red
