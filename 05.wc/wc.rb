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
    print_count(option, stdin.count("\n"), stdin.split(/\s+/).count, stdin.size)
  end
end

def print_files_word_count(option, argv)
  render_error(argv)

  read_file_count_sum = 0
  read_file_word_sum = 0
  file_size_sum = 0

  select_file(argv).each do |file_path|
    read_file = File.read(file_path)
    read_file_count_sum += read_file.count("\n").to_i
    read_file_word_sum += read_file.split(/\s+/).count.to_i
    file_size_sum += read_file.size.to_i

    print_count(option, read_file.count("\n"), read_file.split(/\s+/).count, read_file.size)
    puts "\s#{file_path}"
  end

  return unless argv.length > 1

  print_count(option, read_file_count_sum, read_file_word_sum, file_size_sum)
  puts "\stotal"
end

def render_error(argv)
  argv.each do |file_path|
    puts "ruby wc.rb: #{file_path}: read: Is a directory" if File.directory?(file_path)
    puts "ruby wc.rb: #{file_path}: open: No such file or directory" unless File.exist?(file_path)
  end
end

def print_count(option, line_count, word_count, string_count)
  if no_option?(option)
    print_all(line_count, word_count, string_count)
  else
    print_line_count(line_count) if option['l']
    print_word_count(word_count) if option['w']
    print_string_count(string_count) if option['c']
  end
end

def print_all(line_count, word_count, string_count)
  print_line_count(line_count)
  print_word_count(word_count)
  print_string_count(string_count)
end

def print_line_count(line_count)
  print line_count.to_s.rjust(8)
end

def print_word_count(word_count)
  print word_count.to_s.rjust(8)
end

def print_string_count(string_count)
  print string_count.to_s.rjust(8)
end

def select_file(argv)
  argv.select { |file_path| File.file?(file_path) }
end

def no_option?(option)
  option.all? { |_, v| v == false }
end

main
