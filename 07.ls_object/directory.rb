# frozen_string_literal: true

require_relative 'file_information'

class Directory
  attr_reader :directory_path

  def initialize(directory_path:, include_hidden_file: true, reverse_order: false)
    @directory_path = directory_path
    @include_hidden_file = include_hidden_file
    @reverse_order = reverse_order
  end

  def exclude_hidden_file
    Dir.each_child(@directory_path).to_a.reject { |f| f.start_with?('.') }.sort
  end

  def include_hidden_file
    Dir.each_child(@directory_path).to_a.sort
  end

  def files
    files = @include_hidden_file ? include_hidden_file : exclude_hidden_file
    @reverse_order ? files.reverse : files
  end

  def blocks_sum
    files.map { |f| File.stat("#{@directory_path}/#{f}").blocks }.sum
  end

  def calc_max_length_of_file_stat
    max = { nlink: 0, user: 0, group: 0, size: 0 }
    files.map do |file_name|
      file = FileInformation.new(file_path: "#{@directory_path}/#{file_name}")
      max[:nlink] = file.link_count.length if max[:nlink] < file.link_count.length
      max[:user] = file.owner_name.length if max[:user] < file.owner_name.length
      max[:group] = file.group_name.length if max[:group] < file.group_name.length
      max[:size] = file.byte_size.length if max[:size] < file.byte_size.length
    end
    max
  end
end
