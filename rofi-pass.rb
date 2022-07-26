#!/usr/bin/env ruby

# frozen_string_literal: true

require 'open3'

passwords = Dir.glob('**/*.gpg', base: "#{Dir.home}/.password-store")
passwords.map! { |p| p.chomp.chomp('.gpg') }

selection = ''
Open3.popen3('rofi -dmenu') do |stdin, stdout, _stderr|
  stdin.write(passwords.join("\n"))
  stdin.close
  selection = stdout.read.chomp
end

exit if selection.empty?

# clear selection, since I otherwise often accidentially insert that on paste
`xsel -c`

IO.popen("pass -c #{selection}", 'r') do |pipe|
  # create a wait dialog until password was copied
  zenity = fork do
    exec 'zenity --info --text="Einen Moment ..."'
  end
  output = pipe.gets
  puts output
  Process.kill('HUP', zenity)
end
