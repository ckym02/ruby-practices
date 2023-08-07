#!/usr/bin/env ruby

# frozen_string_literal: true

def main
  # array = [6, 3, 9, 0, 0, 3, 8, 2, 7, 3, 10, 9, 1, 8, 0, 10, 10, 10, 10]
  each_score = ARGV.first.split(',').map! { |elem| elem == 'X' ? 10 : elem.to_i }

  throw_number = 0
  point = 0
  separate_by_frames(each_score).each do |frame|
    if strike?(frame)
      point += frame.first + each_score[throw_number + 1] + each_score[throw_number + 2]
      throw_number += 1
    elsif spare?(frame)
      point += frame.sum + each_score[throw_number + 2]
      throw_number += 2
    else
      point += frame.sum
      throw_number += 2
    end
  end
  puts point
end

# フレームごとのスコアに分ける
# [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10], [9, 1], [8, 0], [10], [10, 10, 10]]
def separate_by_frames(each_score)
  slice_score = each_score.slice_when { |num| num == 10 }.flat_map { |n| n.each_slice(2).to_a }
  slice_score[0..8].push slice_score[9..].flatten
end

def strike?(frame)
  frame.first == 10
end

def spare?(frame)
  frame.sum == 10
end

main
