# frozen_string_literal: true

class Shot
  def initialize(mark)
    @mark = mark
  end

  def score
    return 10 if strike?

    mark.to_i
  end

  private

  attr_accessor :mark

  def strike?
    mark == 'X'
  end
end
