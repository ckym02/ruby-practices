#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'game'

def main
  game = Game.new(ARGV.first.split(','))
  puts game.score
end

main
