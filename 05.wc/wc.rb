#! usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  @option = ARGV.getopts('lwc')
  @argv = ARGV.empty? ? ['.'] : ARGV

  render_error

  read_file_count_sum = 0
  read_file_word_sum = 0
  file_size_sum = 0

  select_file.each do |file_path|
    read_file = File.read(file_path)
    file = File.new(file_path)
    read_file_count_sum += read_file.count("\n").to_i
    read_file_word_sum += read_file.split(/\s+/).count.to_i
    file_size_sum += file.size.to_i

    print_word_count_each_file(read_file, file, file_path)
  end

  print_total_word_count(read_file_count_sum, read_file_word_sum, file_size_sum) if multiple_argv?
end

def render_error
  @argv.each do |file_path|
    puts "ruby wc.rb: #{file_path}: read: Is a directory" if File.directory?(file_path)
    puts "ruby wc.rb: #{file_path}: open: No such file or directory" unless File.exist?(file_path)
  end
end

def print_word_count_each_file(read_file, file, file_path)
  print "#{read_file.count("\n").to_s.rjust(8)}\s" if @option['l'] || no_option?
  print "#{read_file.split(/\s+/).count.to_s.rjust(8)}\s" if @option['w'] || no_option?
  print "#{file.size.to_s.rjust(8)}\s" if @option['c'] || no_option?
  puts file_path
end

def print_total_word_count(read_file_count_sum, read_file_word_sum, file_size_sum)
  print "#{read_file_count_sum.to_s.rjust(8)}\s" if @option['l'] || no_option?
  print "#{read_file_word_sum.to_s.rjust(8)}\s" if @option['w'] || no_option?
  print "#{file_size_sum.to_s.rjust(8)}\s" if @option['c'] || no_option?
  puts 'total'
end

def select_file
  @argv.select { |file_path| File.file?(file_path) }
end

def directory?(file_path)
  File.directory?(file_path)
end

def multiple_argv?
  @argv.length > 1
end

def no_option?
  @option.all? { |_k, v| v == false }
end

def calc_max_length(select_file)
  max = { newlines: 0, words: 0, bytes: 0 }
  select_file.map do |file_path|
    read_file = File.read(file_path)
    file = File.new(file_path)
    max[:newlines] = read_file.count("\n").length if max[:newlines] < read_file.count("\n").length
    max[:words] = read_file.split(/\s+/).count.length if max[:words] < read_file.split(/\s+/).count.length
    max[:bytes] = file.size.length if max[:bytes] < file.size.length
  end
  max
end

# TODO:
# ディレクトリを引数にとる
# ❯ wc ~/Desktop/ruby-practices/05.wc
# wc: /Users/koyama/Desktop/ruby-practices/05.wc: read: Is a directory

# ファイルだと
# wc: /Users/koyama/Desktop/ruby-practices/05.wc/wrb: open: No such file or directory

main
