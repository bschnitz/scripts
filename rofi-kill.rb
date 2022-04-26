#!/usr/bin/env ruby

# frozen_string_literal: true

apps = {
  teams: 'killall -9 teams',
  firefox: 'killall -9 firefox',
  qutebrowser: 'killall -9 qutebrowser',
  signal: 'killall -9 signal'
}

chosen = `echo #{apps.keys.join('#')} | rofi -dmenu -sep '#'`
`#{apps[chosen.chomp.to_sym]}`
