#!/usr/bin/env ruby

require 'open3'

passwords = Dir.glob("**/*.gpg", base: "#{Dir.home}/.password-store")
passwords.map! { |p| p.chomp.chomp('.gpg') }

selection = ''
Open3.popen3("rofi -dmenu") do |stdin, stdout, stderr|
  stdin.write(passwords.join("\n"))
  stdin.close
  selection = stdout.read.chomp
end

exit if selection.empty?

# spawn pass as background task, as it otherwise blocks
Process.detach Process.spawn("pass", "-c", selection)
