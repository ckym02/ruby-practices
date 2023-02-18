#! usr/bin/env ruby

# frozen_string_literal: true

def main
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

    print_hoge(read_file, file, file_path)
  end

  print_total(read_file_count_sum, read_file_word_sum, file_size_sum) if multiple_argv?
end

def render_error
  @argv.each do |file_path|
    return puts "ruby wc.rb: #{file_path}: read: Is a directory" unless File.exist?(file_path)
  end
end

def print_hoge(read_file, file, file_path)
  puts read_file.count("\n")
  # puts read_file.lines.count
  puts read_file.split(/\s+/).count
  puts file.size
  puts file_path
end

def print_total(read_file_count_sum, read_file_word_sum, file_size_sum)
  puts 'total'
  puts read_file_count_sum
  puts read_file_word_sum
  puts file_size_sum
end

def select_file
  @argv.select { |file_path| File.file?(file_path) }
end

def directory?
  @argv.select { |file_path| File.directory?(file_path) }
end

def multiple_argv?
  @argv.length > 1
end

# TODO:
# 複数のファイルを指定すると合計が表示される

# ディレクトリを引数にとる
# ❯ wc ~/Desktop/ruby-practices/05.wc
# wc: /Users/koyama/Desktop/ruby-practices/05.wc: read: Is a directory

# ファイルだと
# wc: /Users/koyama/Desktop/ruby-practices/05.wc/wrb: open: No such file or directory

# 引数がない時は何かを待っている？

main
