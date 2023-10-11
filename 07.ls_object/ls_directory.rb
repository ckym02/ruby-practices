# frozen_string_literal: true

require_relative 'ls_file'

class LsDirectory
  attr_reader :directory_path

  def initialize(directory_path:, include_hidden_file: true, reverse_order: false)
    @directory_path = directory_path
    @include_hidden_file = include_hidden_file
    @reverse_order = reverse_order
  end

  def exclude_hidden_file
    sort_files.reject { |f| f.start_with?('.') }
  end

  def sort_files
    Dir.foreach(@directory_path).to_a.sort
  end

  def files
    files = @include_hidden_file ? sort_files : exclude_hidden_file
    @reverse_order ? files.reverse : files
  end

  def blocks_sum
    files.map { |f| File.stat("#{@directory_path}/#{f}").blocks }.sum
  end

  def calc_max_length_of_file_stat
    max = { nlink: 0, user: 0, group: 0, size: 0 }
    files.map do |file_name|
      file = LsFile.new(file_path: "#{@directory_path}/#{file_name}")
      max[:nlink] = file.link_count.to_s.length if max[:nlink] < file.link_count.to_s.length
      max[:user] = file.owner_name.length if max[:user] < file.owner_name.length
      max[:group] = file.group_name.length if max[:group] < file.group_name.length
      max[:size] = file.byte_size.to_s.length if max[:size] < file.byte_size.to_s.length
    end
    max
  end
end
