#! /usr/bin/env ruby

# frozen_string_literal: true

# 列数
COLUMNS_NUMBER = 3

def main
  directory_path = ARGV.empty? ? '.' : ARGV[0]
  other_than_hidden_files = Dir.each_child(directory_path).reject { |f| f.start_with?('.') }.sort

  swap_rows_and_columns(COLUMNS_NUMBER, other_than_hidden_files).flatten.each.with_index(1) do |file, index|
    (index % COLUMNS_NUMBER).zero? ? (puts file) : (print file)
  end
end

# 行数の計算
def calc_rows(num, files)
  (files.length % num).zero? ? files.length / num : files.length / num + 1
end

# 列ごとの幅を揃える
def adjust_width(file_array)
  file_array.each_with_object([]) do |array, new_array|
    max_num = array.map(&:length).max
    new_array << array.map { |file| "#{file}#{"\s" * (max_num - file.length)}\s\s" }
  end
end

# 行と列を入れ替える
def swap_rows_and_columns(num, files)
  array = []
  rows_number = calc_rows(num, files)
  rows_number.times do |n|
    array << adjust_width(files.each_slice(rows_number)).map { |f| f[n] }
  end
  array
end

main
