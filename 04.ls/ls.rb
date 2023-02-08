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
    @option['l'] ? print_files_details('.', select_file) : print_files(select_file)
  end

  display_files_in_directory
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
    files = @option['a'] ? include_hidden_file(directory_path) : exclude_hidden_file(directory_path)
    files_for_display = @option['r'] ? files.reverse : files
    break if files_for_display.empty?

    puts "#{directory_path}:" if multiple_argv?

    if @option['l']
      puts "total #{blocks_sum(directory_path, files_for_display)}"
      print_files_details(directory_path, files_for_display)
    else
      print_files(files_for_display)
    end
  end
end

def exclude_hidden_file(directory_path)
  Dir.each_child(directory_path).to_a.reject { |f| f.start_with?('.') }.sort
end

def include_hidden_file(directory_path)
  Dir.each_child(directory_path).to_a.sort
end

def multiple_argv?
  @argv.length > 1
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

def print_files_details(directory_path, files_for_display)
  files_for_display.each do |file|
    stat = File.stat("#{directory_path}/#{file}")
    max_length = calc_max_length(directory_path, files_for_display)
    type = stat.ftype == 'file' ? '-' : stat.ftype[0]
    print "#{type}#{PERMISSION[stat.mode.to_s(8)[-3]]}#{PERMISSION[stat.mode.to_s(8)[-2]]}#{PERMISSION[stat.mode.to_s(8)[-1]]}\s\s"
    print "#{stat.nlink.to_s.rjust(max_length[:nlink])}\s"
    print "#{Etc.getpwuid(stat.uid).name.rjust(max_length[:user])}\s\s"
    print "#{Etc.getgrgid(stat.gid).name.rjust(max_length[:group])}\s\s"
    print "#{stat.size.to_s.rjust(max_length[:size])}\s"
    print "#{stat.mtime.month.to_s.rjust(2)}\s"
    print "#{stat.mtime.day.to_s.rjust(2)}\s"
    print "#{stat.mtime.strftime('%H:%M')}\s"
    puts file
  end
  puts "\n" if multiple_argv?
end

def calc_max_length(directory_path, files_for_display)
  max = { nlink: 0, user: 0, group: 0, size: 0 }
  files_for_display.map do |file|
    stat = File.stat("#{directory_path}/#{file}")
    max[:nlink] = stat.nlink.to_s.length if max[:nlink] < stat.nlink.to_s.length
    max[:user] = Etc.getpwuid(stat.uid).name.to_s.length if max[:user] < Etc.getpwuid(stat.uid).name.to_s.length
    max[:group] = Etc.getgrgid(stat.gid).name.to_s.length if max[:group] < Etc.getgrgid(stat.gid).name.to_s.length
    max[:size] = stat.size.to_s.length if max[:size] < stat.size.to_s.length
  end
  max
end

def blocks_sum(directory_path, files_for_display)
  files_for_display.map { |f| File.stat("#{directory_path}/#{f}").blocks }.sum
end

PERMISSION = {
  '0' => '---',
  '1' => '--x',
  '2'	=> '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

main
