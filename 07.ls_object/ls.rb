#! /usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'ls_file'
require_relative 'ls_directory'

# 列数
COLUMNS_NUMBER = 3

def main
  @option = ARGV.getopts('arl')
  @argv = ARGV.empty? ? ['.'] : ARGV

  render_error

  unless select_file.empty?
    directory = LsDirectory.new(directory_path: '.', include_hidden_file: @option['a'], reverse_order: @option['r'])
    @option['l'] ? print_files_details(directory, select_file) : print_files(select_file)
  end

  display_files_in_directory
end

def multiple_argv?
  @argv.length > 1
end

def render_error
  @argv.each do |file_path|
    puts "ruby ls.rb: #{file_path}: No such file or directory" unless File.exist?(file_path)
  end
end

def select_file
  @argv.select { |file_path| File.file?(file_path) }
end

def select_directory
  @argv.select { |file_path| File.directory?(file_path) }
end

def display_files_in_directory
  select_directory.each do |directory_path|
    directory = LsDirectory.new(directory_path:, include_hidden_file: @option['a'], reverse_order: @option['r'])
    files_for_display = directory.files
    break if files_for_display.empty?

    puts "#{directory_path}:" if @argv.length > 1

    if @option['l']
      puts "total #{directory.blocks_sum}"
      print_files_details(directory, files_for_display)
    else
      print_files(files_for_display)
    end
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
    new_array << array.map { |file| "#{file.ljust(max_num)}\s\s" }
  end
end

def print_files_details(directory, files_for_display)
  max_length = directory.calc_max_length_of_file_stat
  files_for_display.each do |file_name|
    file = LsFile.new(file_path: "#{directory.directory_path}/#{file_name}", stat_max_length: max_length)
    print file.detail
    puts file_name
  end
  puts "\n" if multiple_argv?
end

main
