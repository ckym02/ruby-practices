# frozen_string_literal: true

require_relative 'ls_file'

class LsDirectory
  def initialize(directory_path, hidden_file_presence: true, reversed_order: false)
    @directory_path = directory_path
    @hidden_file_presence = hidden_file_presence
    @reversed_order = reversed_order
  end

  def ls_files
    @ls_files ||= prepare_ls_files
  end

  def blocks_sum
    @ls_files.sum(&:blocks)
  end

  private

  def prepare_ls_files
    directory_files = Dir.foreach(@directory_path).to_a
    filtered_files = @hidden_file_presence ? directory_files : exclude_hidden_files(directory_files)
    ordered_files = @reversed_order ? filtered_files.sort.reverse : filtered_files.sort
    ordered_files.map do |file|
      file_path = File.join(@directory_path, file)
      LsFile.new(file_path)
    end
  end

  def exclude_hidden_files(directory_files)
    directory_files.reject { |f| f.start_with?('.') }
  end
end
