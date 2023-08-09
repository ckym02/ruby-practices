#!/usr/bin/env ruby

# frozen_string_literal: true

require './game'

def main
  argv = ARGV.first.split(',')
  game = Game.new(argv)
  puts game.score
end

main
