#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'game'

def main
  argv = ARGV.first.split(',')
  game = Game.new(argv)
  puts game.score
end

main
