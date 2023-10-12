#! /usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'ls_file'
require_relative 'ls_directory'

# 列数
COLUMNS_NUMBER = 3

def main
  option = ARGV.getopts('arl')

  display_files_in_directory('.', option)
end

def display_files_in_directory(directory_path, option)
  directory = LsDirectory.new(directory_path:, hidden_files_presence: option['a'], reversed_order: option['r'])
  files_in_directory = directory.file_lists
  return if files_in_directory.empty?

  if option['l']
    puts "total #{directory.blocks_sum}"
    print_files_details(files_in_directory)
  else
    print_files(files_in_directory)
  end
end

def print_files(files_in_directory)
  rows_number = files_in_directory.length.ceildiv(COLUMNS_NUMBER)
  max_num = files_in_directory.map { |file| file.file_name.length }.max
  adjusted_files = adjust_width(align_array_size(rows_number, files_in_directory), max_num)
  transposed_files = adjusted_files.each_slice(rows_number).to_a.transpose

  transposed_files.each do |file_array|
    file_array[-1] += "\n"
    file_array.each { |f| print f }
  end
end

def align_array_size(rows_number, files)
  if (files.length % rows_number).zero?
    files
  else
    files + Array.new(rows_number - files.length % rows_number, LsFile.new(file_path: '', file_name: ''))
  end
end

def adjust_width(file_array, max_num)
  file_array.map { |file| "#{file.file_name.ljust(max_num)}\s\s" }
end

def print_files_details(files_in_directory)
  stat_max_length = calc_max_length_of_file_stat(files_in_directory)
  files_in_directory.each do |file|
    print file_detail(file, stat_max_length)
    puts file.file_name
  end
end

def file_detail(file, stat_max_length)
  "#{file.type}#{file.permission}#{file.display_extended_attribute}\s" \
    "#{file.link_count.to_s.rjust(stat_max_length[:nlink])}\s" \
    "#{file.owner_name.rjust(stat_max_length[:user])}\s\s" \
    "#{file.group_name.rjust(stat_max_length[:group])}\s\s" \
    "#{file.byte_size.to_s.rjust(stat_max_length[:size])}\s" \
    "#{file.time_stamp}\s"
end

def calc_max_length_of_file_stat(files)
  max = { nlink: 0, user: 0, group: 0, size: 0 }
  files.map do |file|
    max[:nlink] = file.link_count.to_s.length if max[:nlink] < file.link_count.to_s.length
    max[:user] = file.owner_name.length if max[:user] < file.owner_name.length
    max[:group] = file.group_name.length if max[:group] < file.group_name.length
    max[:size] = file.byte_size.to_s.length if max[:size] < file.byte_size.to_s.length
  end
  max
end

main
