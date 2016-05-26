#!/usr/bin/env ruby

require 'optparse'


# オプションをパース
option = { placeholder: '{}', linenum_placeholder: '{linenum}' }
OptionParser.new do |opt|
  opt.on('-p', '--placeholder=TEXT',         '入力行で置き換える文字列') {|v| option[:placeholder]         = v}
  opt.on('-l', '--linenum-placeholder=TEXT', '行数で置き換える文字列')   {|v| option[:linenum_placeholder] = v}
  opt.parse!(ARGV)
end


# 引数から条件式のテンプレートを生成
condition_template = ARGV.join(' ')

# 標準入力を 1 行ずつ処理
linenum = 0
while line = STDIN.gets
  # 入力行の行末改行文字を削除して扱いやすくする
  line.chomp!

  # 条件式のテンプレートの一部を入力行と行番号で置換して、条件式を生成
  condition = condition_template
  condition = condition.gsub(option[:placeholder], line)
  condition = condition.gsub(option[:linenum_placeholder], linenum.to_s)

  # 条件式を実行し、終了ステータスが成功なら入力行を出力
  system(condition)
  puts line if $? == 0

  linenum += 1
end
