#! usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'

def main
  option = ARGV.getopts('lwc')
  argv = ARGV

  if !argv.empty?
    print_files_word_count(option, argv)
  else
    stdin = $stdin.read
    print_word_count(option, stdin.count("\n"), stdin.split(/\s+/).count, stdin.size)
  end
end

def print_files_word_count(option, argv)
  render_error(argv)

  read_file_count_sum = 0
  read_file_word_sum = 0
  file_size_sum = 0

  select_file(argv).each do |file_path|
    read_file = File.read(file_path)
    file = File.new(file_path)
    read_file_count_sum += read_file.count("\n").to_i
    read_file_word_sum += read_file.split(/\s+/).count.to_i
    file_size_sum += file.size.to_i

    print_word_count(option, read_file.count("\n"), read_file.split(/\s+/).count, file.size)
    puts "\s#{file_path}"
  end

  return unless multiple_argv?(argv)

  print_word_count(option, read_file_count_sum, read_file_word_sum, file_size_sum)
  puts "\stotal"
end

def render_error(argv)
  argv.each do |file_path|
    puts "ruby wc.rb: #{file_path}: read: Is a directory" if File.directory?(file_path)
    puts "ruby wc.rb: #{file_path}: open: No such file or directory" unless File.exist?(file_path)
  end
end

def print_word_count(option, read_file_count, read_file_word, file_size)
  if no_option?(option)
    print read_file_count.to_s.rjust(8)
    print read_file_word.to_s.rjust(8)
    print file_size.to_s.rjust(8)
  end
  print read_file_count.to_s.rjust(8) if option['l']
  print read_file_word.to_s.rjust(8) if option['w']
  print file_size.to_s.rjust(8) if option['c']
end

def select_file(argv)
  argv.select { |file_path| File.file?(file_path) }
end

def directory?(file_path)
  File.directory?(file_path)
end

def multiple_argv?(argv)
  argv.length > 1
end

def no_option?(option)
  option.all? { |_, v| v == false }
end

main
