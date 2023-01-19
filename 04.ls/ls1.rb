#! /usr/bin/env ruby

# frozen_string_literal: true

# 列数
COLUMNS_NUMBER = 3

def main
  render_error

  print_files(select_file(argv)) unless select_file(argv).empty?

  select_directory(argv).each do |file_path|
    other_than_hidden_files = Dir.each_child(file_path).reject { |f| f.start_with?('.') }
    break if other_than_hidden_files.empty?

    puts "#{file_path}:" if multiple_argv?
    print_files(other_than_hidden_files)
  end
end

def select_directory(argv)
  argv.select { |file_path| File.directory?(file_path) }
end

def select_file(argv)
  argv.select { |file_path| File.file?(file_path) }
end

def argv
  ARGV.empty? ? ['.'] : ARGV
end

def multiple_argv?
  argv.length > 1
end

def render_error
  argv.each do |file_path|
    puts "ruby ls1.rb: #{file_path}: No such file or directory" unless File.exist?(file_path)
  end
end

def print_files(files)
  rows_number = files.length.ceildiv(COLUMNS_NUMBER)
  transposed_files = adjust_width(align_array_size(rows_number, files.sort).each_slice(rows_number)).transpose

  transposed_files.each do |file_array|
    file_array[-1] += "\n"
    file_array.each { |f| print f }
  end

  puts "\n" if multiple_argv?
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
