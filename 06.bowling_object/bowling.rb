#!/usr/bin/env ruby

# frozen_string_literal: true

require './game'

def main
  # ["6", "3", "9", "0", "0", "3", "8", "2", "7", "3", "X", "9", "1", "8", "0", "X", "6", "4", "5"]
  argv = ARGV.first.split(',')
  game = Game.new(argv)
  puts game.score
end

main
