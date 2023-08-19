# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  def initialize(marks)
    @scores = marks.map { |mark| Shot.new(mark).score }
  end

  def score
    total_score = 0
    shot_number = 1
    separate_by_frames.each.with_index(1) do |frame, frame_number|
      frame = Frame.new(first_score: frame[0], second_score: frame[1], third_score: frame[2])

      if frame.strike? && frame_number != 10
        total_score += frame.score + @scores[shot_number] + @scores[shot_number + 1]
        shot_number += 1
      elsif frame.spare? && frame_number != 10
        total_score += frame.score + @scores[shot_number + 1]
        shot_number += 2
      else
        total_score += frame.score
        shot_number += 2
      end
    end
    total_score
  end

  private

  # フレームごとのスコアに分ける
  # [[6, 3], [9, 0], [0, 3], [8, 2], [7, 3], [10], [9, 1], [8, 0], [10], [6, 4, 5]]
  def separate_by_frames
    slice_score = @scores.slice_when { |score| score == 10 }.flat_map { |n| n.each_slice(2).to_a }
    slice_score[0..8].push slice_score[9..].flatten
  end
end
