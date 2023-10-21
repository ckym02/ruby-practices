# frozen_string_literal: true

require_relative 'ls_file'

class LsDirectory
  attr_reader :ls_files

  def initialize(directory_path, hidden_file_presence: true, reversed_order: false)
    @directory_path = directory_path
    @hidden_file_presence = hidden_file_presence
    @reversed_order = reversed_order
    @ls_files = prepare_ls_files
  end

  def blocks_sum
    @ls_files.sum(&:blocks)
  end

  private

  def prepare_ls_files
    filtered_files = @hidden_file_presence ? directory_files : exclude_hidden_files
    ordered_files = @reversed_order ? filtered_files.sort.reverse : filtered_files.sort
    ordered_files.map { |file| LsFile.new(@directory_path, file) }
  end

  def exclude_hidden_files
    directory_files.reject { |f| f.start_with?('.') }
  end

  def directory_files
    Dir.foreach(@directory_path).to_a
  end
end
