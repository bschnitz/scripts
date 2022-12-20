#!/usr/bin/env ruby

# frozen_string_literal: true

temp_dir = '/home/ben/data/projects/work/kemas/temp/ppn'

Dir["#{temp_dir}/*"].each do |file|
  passcode = File.read(file)[%r{<b>([0-9]{6})</b>}, 1]
  IO.popen('xsel -ib', 'w') { |pipe| pipe.print passcode }
  File.unlink file
end
