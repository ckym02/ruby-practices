#! /usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require 'etc'

# 列数
COLUMNS_NUMBER = 3

def main
  @option = ARGV.getopts('arl')
  @argv = ARGV.empty? ? ['.'] : ARGV

  render_error

  unless select_file.empty?
    @option['l'] ? print_files_details(select_file) : print_files(select_file)
  end

  select_directory.each do |file_path|
    files = @option['a'] ? include_hidden_file(file_path) : exclude_hidden_file(file_path)
    files_for_display = @option['r'] ? files.reverse : files
    break if files_for_display.empty?

    puts "#{file_path}:" if multiple_argv?
    @option['l'] ? print_files_details(file_path, files_for_display) : print_files(files_for_display)
  end
end

def enum(role)
  {
    '0' => '---',
    '1' => '--x',
    '2'	=> '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[role]
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

def print_files_details(file_path, files_for_display)
  puts "total #{hogehoge(files_for_display, file_path)[:block_sum]}" if @option['l']
  files_for_display.each do |file|
    stat = File.stat("#{file_path}/#{file}")
    type = stat.ftype == 'file' ? '-' : stat.ftype[0]
    print "#{type}#{enum(stat.mode.to_s(8)[-3])}#{enum(stat.mode.to_s(8)[-2])}#{enum(stat.mode.to_s(8)[-1])}\s\s"
    print "#{stat.nlink.to_s.rjust(hogehoge(files_for_display, file_path)[:nlink_max])}\s"
    print "#{Etc.getpwuid(stat.uid).name.rjust(hogehoge(files_for_display, file_path)[:user_max])}\s\s"
    print "#{Etc.getgrgid(stat.gid).name.rjust(hogehoge(files_for_display, file_path)[:group_max])}\s\s"
    print "#{stat.size.to_s.rjust(hogehoge(files_for_display, file_path)[:size_max])}\s"
    print "#{stat.mtime.month.to_s.rjust(2)}\s"
    print "#{stat.mtime.day.to_s.rjust(2)}\s"
    print "#{stat.mtime.strftime('%H:%M')}\s"
    puts file
  end
end

def hogehoge(files_for_display, file_path)
  max = { block_sum: 0, nlink_max: 0, user_max: 0, group_max: 0, size_max: 0 }
  files_for_display.map do |file|
    stat = File.stat("#{file_path}/#{file}")
    max[:block_sum] += stat.blocks
    max[:nlink_max] = stat.nlink.to_s.length if max[:nlink_max] < stat.nlink.to_s.length
    max[:user_max] = Etc.getpwuid(stat.uid).name.to_s.length if max[:user_max] < Etc.getpwuid(stat.uid).name.to_s.length
    max[:group_max] = Etc.getgrgid(stat.gid).name.to_s.length if max[:group_max] < Etc.getgrgid(stat.gid).name.to_s.length
    max[:size_max] = stat.size.to_s.length if max[:size_max] < stat.size.to_s.length
  end
  max
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
