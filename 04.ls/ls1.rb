# TODO:
# シバン追加
# パス通す
# 例外処理
# 引数の値を破壊的に変えてしまうのであればメソッド名に!をつけてる

# 引数にファイルやディレクトリを指定可能にする。
# 半角英数字以外のファイル名（ひらがなや漢字など）を持つファイルがあっても表示が崩れない。
# mac拡張属性（@マークで表示される）に対応する。( Mac OS の利用者のみ )

require 'optparse'

LINE_NUMBER = 3

def main
  directory_path = ARGV[0]
  other_than_hidden_files = Dir.each_child(directory_path).select { |f| !f.start_with?('.') }

  hoge(LINE_NUMBER, other_than_hidden_files.sort).flatten.each.with_index(1) do |h, i|
    i % LINE_NUMBER == 0 ? (puts h) : (print h)
  end
end

# 行と列を入れ替え
def hoge(num, files)
  array = []
  rows_number = calc_rows(num, files)
  rows_number.times do |n|
    array << adjust_width(files.each_slice(rows_number)).map { |f| f[n] }
  end
  array
end

# 何行にするか
def calc_rows(num, files)
  files.length % num == 0 ? files.length / num : files.length / num + 1
end

def adjust_width(file_array)
  file_array.each_with_object([]) do |array, new_array|
    max_num = array.map(&:length).max
    new_array << array.map { |file| file + "\s" * (max_num - file.length) + "\s\s" }
  end
end

main
