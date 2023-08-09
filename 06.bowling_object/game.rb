# frozen_string_literal: true

require './frame'
require './shot'

class Game
  def initialize(all_scores)
    @all_scores = all_scores
  end

  def score
    total_score = 0
    shot_number = 1
    separate_by_frames.each do |scores|
      frame = Frame.new(first_mark: scores[0], second_mark: scores[1], third_mark: scores[2])

      if frame.strike?
        total_score += frame.score + shot_score(shot_number + 1) + shot_score(shot_number + 2)
        shot_number += 1
      elsif frame.spare?
        total_score += frame.score + shot_score(shot_number + 2)
        shot_number += 2
      else
        total_score += frame.score
        shot_number += 2
      end
    end
    total_score
  end

  private

  attr_accessor :all_scores

  def shot_score(shot_number)
    Shot.new(all_scores[shot_number - 1]).score
  end

  # フレームごとのスコアに分ける
  # [['6', '3'], ['9', '0'], ['0', '3'], ['8', '2'], ['7', '3'], ['X'], ['9', '1'], ['8', '0'], ['X'], ['X', 'X', 'X']]
  def separate_by_frames
    slice_score = all_scores.slice_when { |score| score == 'X' }.flat_map { |n| n.each_slice(2).to_a }
    slice_score[0..8].push slice_score[9..].flatten
  end
end
