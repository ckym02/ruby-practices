# frozen_string_literal: true

class FileInformation
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

  def initialize(file_path:, stat_max_length: {})
    @file_path = file_path
    @nlink_length = stat_max_length[:nlink] || 0
    @user_length = stat_max_length[:user] || 0
    @group_length = stat_max_length[:group] || 0
    @size_length = stat_max_length[:size] || 0
  end

  def stat
    File.stat(@file_path.to_s)
  end

  def type
    stat.ftype == 'file' ? '-' : stat.ftype[0]
  end

  def permission
    "#{PERMISSION[stat.mode.to_s(8)[-3]]}#{PERMISSION[stat.mode.to_s(8)[-2]]}#{PERMISSION[stat.mode.to_s(8)[-1]]}"
  end

  def link_count
    stat.nlink.to_s
  end

  def owner_name
    Etc.getpwuid(stat.uid).name.to_s
  end

  def group_name
    Etc.getgrgid(stat.gid).name.to_s
  end

  def byte_size
    stat.size.to_s
  end

  def time_stamp
    "#{stat.mtime.month.to_s.rjust(2)}\s#{stat.mtime.day.to_s.rjust(2)}\s#{stat.mtime.strftime('%H:%M')}"
  end

  def detail
    "#{type}#{permission}#{display_extended_attribute}\s" \
      "#{link_count.rjust(@nlink_length)}\s#{owner_name.rjust(@user_length)}\s\s#{group_name.rjust(@group_length)}\s\s#{byte_size.rjust(@size_length)}\s" \
      "#{time_stamp}\s"
  end

  def display_extended_attribute
    return "\s" if extended_attributes.empty?

    '@'
  end

  def extended_attributes
    `xattr "#{@file_path}"`
  end
end
