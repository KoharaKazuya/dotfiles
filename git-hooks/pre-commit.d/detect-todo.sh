if added_text_by_commit | grep -iE 'todo|fixme'; then
  warn 'コミットに TODO もしくは FIXME が含まれます'
  show_ignore_variable
  false
fi
