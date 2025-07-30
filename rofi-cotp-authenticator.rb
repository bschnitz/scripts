#!/usr/bin/env ruby

# frozen_string_literal: true

require 'open3'
require 'json'

auth_app_pass_path = 'security/two-factor/cotp'
pass = `pass #{auth_app_pass_path}`
export_path = './export.cotp'
File.exist?(export_path) && File.unlink(export_path)
IO.popen("cotp --password-stdin export -p #{export_path}", mode: 'w') do |io|
  io.write(pass)
  io.close
end
export = JSON.parse(File.read(export_path))
File.exist?(export_path) && File.unlink(export_path)

selections = export['elements'].map do |el|
  [
    { name: 'Issuer:', content: el['issuer'] },
    { name: 'Label:', content: el['label'] }
  ]
end
selections.map! { |elements| elements.map { |el| "#{el[:name]} #{el[:content]}" } }
          .map! { |elements| elements.map { |el| el.ljust(30) } }
          .map! { |elements| elements.join(' ++ ') }

selection = ''
Open3.popen3('rofi -dmenu') do |stdin, stdout, _stderr|
  stdin.write(selections.join("\n"))
  stdin.close
  selection = stdout.read.chomp
end

issuer, label = selection.match(/Issuer: (.*) \+\+ Label: (.*)/).captures.map(&:strip)

IO.popen("cotp --password-stdin extract -s '#{issuer}' -l '#{label}'", mode: 'r+') do |io|
  io.write(pass)
  io.close_write
  otp = io.read.strip
  IO.popen('xsel -ib', mode: 'w') do |xsel|
    xsel.write(otp)
  end
end
