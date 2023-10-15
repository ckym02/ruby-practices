# frozen_string_literal: true

class LsFile
  PERMISSION = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  attr_reader :file_name

  def initialize(directory_path:, file_name:)
    @file_path = "#{directory_path}/#{file_name}"
    @file_name = file_name
  end

  def type
    stat.ftype == 'file' ? '-' : stat.ftype[0]
  end

  def permission
    "#{PERMISSION[stat.mode.to_s(8)[-3]]}#{PERMISSION[stat.mode.to_s(8)[-2]]}#{PERMISSION[stat.mode.to_s(8)[-1]]}"
  end

  def link_count
    stat.nlink
  end

  def owner_name
    Etc.getpwuid(stat.uid).name
  end

  def group_name
    Etc.getgrgid(stat.gid).name
  end

  def byte_size
    stat.size
  end

  def modify_time
    stat.mtime
  end

  def blocks
    stat.blocks
  end

  def extended_attributes
    `xattr "#{@file_path}"`
  end

  private

  def stat
    File.stat(@file_path.to_s)
  end
end
