#! /usr/bin/env ruby

require 'optparse'
require 'date'

params = ARGV.getopts('m:', 'y:')
month = params['m'].nil? ? Date.today.month : params['m'].to_i
year = params['y'].nil? ? Date.today.year : params['y'].to_i

last_day = Date.new(year, month, -1).day
last_month_days = Date.new(year, month, 1).wday

puts  "\s\s\s\s\s\s#{month}月\s#{year}"
puts  "日 月 火 水 木 金 土"
last_month_days.times { print "\s\s\s" }
(1..last_day).each do |d|
  date = Date.new(year, month, d)
  day = Date.today == date ? "\e[30m\e[47m\e[5m" + date.strftime("%e") + "\e[0m" : date.strftime("%e")

  print day + "#{ date.saturday? ? "\n" : "\s" }"
end
