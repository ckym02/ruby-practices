#! /usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

# 列数
COLUMNS_NUMBER = 3

def main
  @option = ARGV.getopts('ar')
  @argv = ARGV.empty? ? ['.'] : ARGV

  render_error

  print_files(select_file) unless select_file.empty?

  select_directory.each do |file_path|
    files = @option['a'] ? include_hidden_file(file_path) : exclude_hidden_file(file_path)
    files_for_display = @option['r'] ? files.reverse : files
    break if files_for_display.empty?

    puts "#{file_path}:" if multiple_argv?
    print_files(files_for_display)
  end
end

def select_directory
  @argv.select { |file_path| File.directory?(file_path) }
end

def select_file
  @argv.select { |file_path| File.file?(file_path) }
end

def exclude_hidden_file(file_path)
  Dir.each_child(file_path).to_a.reject { |f| f.start_with?('.') }.sort
end

def include_hidden_file(file_path)
  Dir.each_child(file_path).to_a.sort
end

def multiple_argv?
  @argv.length > 1
end

def render_error
  @argv.each do |file_path|
    puts "ruby ls.rb: #{file_path}: No such file or directory" unless File.exist?(file_path)
  end
end

def print_files(files)
  rows_number = files.length.ceildiv(COLUMNS_NUMBER)
  transposed_files = adjust_width(align_array_size(rows_number, files).each_slice(rows_number)).transpose

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
