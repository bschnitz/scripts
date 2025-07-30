#!/usr/bin/env ruby

ticket_pattern = "(movesito|movesp|mobit).([0-9]+)"
branch_pattern = "(bugfix\/|feature\/|)#{ticket_pattern}"

lines = File.readlines(ARGV[1]).drop_while { |line| line =~ /\s*#/ }
message = lines[0]

if message =~ /^#{ticket_pattern}/i
  # already prefixed by ticket name
  exit 0
end

branch = `git rev-parse --abbrev-ref HEAD`
ticket_match = branch.match(/#{branch_pattern}/i)

if not ticket_match
  puts 'could not determine jira ticket name, aborting.'
  puts 'use "git commit --no-verify" to bypass this check.'
  exit 1
end

ticket = ticket_match.captures[1..2].join('-').upcase

lines = ["#{ticket} #{message}"] + lines[1..]
File.write(ARGV[1], lines.join(''))
exit 0
