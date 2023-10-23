#! /usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'
require_relative 'ls_directory'

COLUMNS_NUMBER = 3

def main
  option = ARGV.getopts('arl')

  display_files_in_directory('.', option)
end

def display_files_in_directory(directory_path, option)
  directory = LsDirectory.new(directory_path, hidden_file_presence: option['a'], reversed_order: option['r'])
  ls_files = directory.ls_files
  return if ls_files.empty?

  if option['l']
    puts "total #{directory.blocks_sum}"
    print_files_details(ls_files)
  else
    print_files(ls_files)
  end
end

def print_files(ls_files)
  rows_number = ls_files.length.ceildiv(COLUMNS_NUMBER)
  aligned_files = align_array_size(rows_number, ls_files)
  transposed_files = aligned_files.each_slice(rows_number).to_a.transpose

  file_name_max_length = ls_files.map { |ls_file| ls_file.name.length }.max
  transposed_files.each do |ls_file_lists|
    ls_file_lists.each { |ls_file| print "#{ls_file&.name&.ljust(file_name_max_length)}\s\s" }
    print "\n"
  end
end

def align_array_size(rows_number, ls_files)
  modulo_files = ls_files.length % rows_number
  if modulo_files.zero?
    ls_files
  else
    ls_files + Array.new(rows_number - modulo_files)
  end
end

def print_files_details(ls_files)
  max_lengths = calc_max_length_of_file_stat(ls_files)
  ls_files.each do |ls_file|
    puts build_file_detail(ls_file, max_lengths)
  end
end

def calc_max_length_of_file_stat(ls_files)
  max = { nlink: 0, user: 0, group: 0, size: 0 }
  ls_files.each do |ls_file|
    max[:nlink] = ls_file.link_count.to_s.length if max[:nlink] < ls_file.link_count.to_s.length
    max[:user] = ls_file.owner_name.length if max[:user] < ls_file.owner_name.length
    max[:group] = ls_file.group_name.length if max[:group] < ls_file.group_name.length
    max[:size] = ls_file.byte_size.to_s.length if max[:size] < ls_file.byte_size.to_s.length
  end
  max
end

def build_file_detail(ls_file, max_lengths)
  "#{ls_file.type}#{ls_file.permission}#{display_extended_attribute(ls_file)}\s" \
    "#{ls_file.link_count.to_s.rjust(max_lengths[:nlink])}\s" \
    "#{ls_file.owner_name.ljust(max_lengths[:user])}\s\s" \
    "#{ls_file.group_name.ljust(max_lengths[:group])}\s\s" \
    "#{ls_file.byte_size.to_s.rjust(max_lengths[:size])}\s" \
    "#{build_time_stamp(ls_file)}\s" \
    "#{ls_file.name}"
end

def display_extended_attribute(ls_file)
  return "\s" if ls_file.extended_attributes.empty?

  '@'
end

def build_time_stamp(ls_file)
  ls_file.modify_time.strftime('%_m %_d %H:%M')
end

main
