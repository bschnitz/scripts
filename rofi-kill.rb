#!/usr/bin/env ruby

apps = {
  teams: 'killall -9 teams',
  firefox: 'killall -9 firefox',
  qutebrowser: 'killall -9 qutebrowser',
  signal: 'killall -9 signal',
  sqlitestudio: 'killall -9 sqlitestudio'
}

chosen = `echo #{apps.keys.join('#')} | rofi -dmenu -sep '#'`
`#{apps[chosen.chomp.to_sym]}`
