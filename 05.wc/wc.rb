#! usr/bin/env ruby

def main
  @argv = ARGV.empty? ? ['.'] : ARGV
  @argv.each do |file_path|
    return puts "ruby wc.rb: #{file_path}: read: Is a directory"
    select_file.each do |file_path|
      read_file = File.read(file_path)
      file = File.new(file_path)
      puts read_file.count("\n")
      # puts read_file.lines.count
      puts read_file.split(/\s+/).count
      puts file.size
      puts file_path
      puts "total" if multiple_argv?
    end
  end
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
# ワイルドカード

# ディレクトリを引数にとる
# ❯ wc ~/Desktop/ruby-practices/05.wc
# wc: /Users/koyama/Desktop/ruby-practices/05.wc: read: Is a directory

# 引数がない時は何かを待っている？

main