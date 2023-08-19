# frozen_string_literal: true

class Frame
  def initialize(first_score:, second_score:, third_score:)
    @first_score = first_score
    @second_score = second_score || 0
    @third_score = third_score || 0
  end

  def score
    @first_score + @second_score + @third_score
  end

  def strike?
    @first_score == 10
  end

  def spare?
    @first_score + @second_score == 10
  end
end
