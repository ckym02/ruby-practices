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
    filtered_files = @include_hidden_file ? sort_files : exclude_hidden_file
    ordered_files = @reverse_order ? filtered_files.reverse : filtered_files
    ordered_files.map { |file| LsFile.new(file_path: "#{@directory_path}/#{file}", file_name: file) }
  end

  def blocks_sum
    files.map(&:blocks).sum
  end
end
