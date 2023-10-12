# frozen_string_literal: true

require_relative 'ls_file'

class LsDirectory
  attr_reader :directory_path

  def initialize(directory_path:, hidden_files_presence: true, reversed_order: false)
    @directory_path = directory_path
    @hidden_files_presence = hidden_files_presence
    @reversed_order = reversed_order
  end

  def exclude_hidden_files
    sort_files.reject { |f| f.start_with?('.') }
  end

  def sort_files
    Dir.foreach(@directory_path).to_a.sort
  end

  def file_lists
    filtered_files = @hidden_files_presence ? sort_files : exclude_hidden_file
    ordered_files = @reversed_order ? filtered_files.reverse : filtered_files
    ordered_files.map { |file| LsFile.new(file_path: "#{@directory_path}/#{file}", file_name: file) }
  end

  def blocks_sum
    file_lists.map(&:blocks).sum
  end
end
