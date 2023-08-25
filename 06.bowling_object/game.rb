# frozen_string_literal: true

require_relative 'frame'
require_relative 'shot'

class Game
  def initialize(marks)
    @shots = marks.map { |mark| Shot.new(mark) }
  end

  def score
    total_score = 0
    shot_number = 1
    generate_frames.each.with_index(1) do |frame, frame_number|
      if frame.strike? && frame_number != 10
        total_score += frame.score + @shots[shot_number].score + @shots[shot_number + 1].score
        shot_number += 1
      elsif frame.spare? && frame_number != 10
        total_score += frame.score + @shots[shot_number + 1].score
        shot_number += 2
      else
        total_score += frame.score
        shot_number += 2
      end
    end
    total_score
  end

  private

  # フレームごとにshotを分割する
  def separate_shots
    slice_score = @shots.slice_when { |shot, _| shot.strike? }.flat_map { |n| n.each_slice(2).to_a }
    slice_score[0..8].push slice_score[9..].flatten
  end

  # frameオブジェクトの配列を作成する
  def generate_frames
    separate_shots.map do |shots|
      Frame.new(first_shot: shots[0], second_shot: shots[1] || Shot.new, third_shot: shots[2] || Shot.new)
    end
  end
end
