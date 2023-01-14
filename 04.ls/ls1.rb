#! /usr/bin/env ruby

# frozen_string_literal: true

# 列数
COLUMNS_NUMBER = 3

def main
  argv = ARGV.empty? ? ['.'] : ARGV

  argv.each do |file_path|
    return puts "ruby ls1.rb: #{file_path}: No such file or directory" unless File.exist?(file_path)

    puts "#{file_path}:" if argv.length != 1 && File.directory?(file_path)
    File.directory?(file_path) ? print_files(file_path) : (puts file_path)
    puts "\n" if argv.length != 1
  end
end

def print_files(file_path)
  other_than_hidden_files = Dir.each_child(file_path).reject { |f| f.start_with?('.') }.sort
  rows_number = other_than_hidden_files.length.ceildiv(COLUMNS_NUMBER)
  transposed_files = adjust_width(align_array_size(rows_number, other_than_hidden_files).each_slice(rows_number)).transpose

  transposed_files.flatten.each.with_index(1) do |file, index|
    (index % COLUMNS_NUMBER).zero? ? (puts file) : (print file)
  end
end

# 配列の各要素のサイズを揃える
def align_array_size(rows_number, files)
  (files.length % rows_number).zero? ? files : files + Array.new(rows_number - files.length % rows_number, '')
end

# 列ごとの幅を揃える
def adjust_width(file_array)
  file_array.each_with_object([]) do |array, new_array|
    max_num = array.map(&:length).max
    new_array << array.map { |file| "#{file}#{"\s" * (max_num - file.length)}\s\s" }
  end
end

main
