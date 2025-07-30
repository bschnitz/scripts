#!/usr/bin/env ruby

# frozen_string_literal: true

require 'open3'

class I3Workspaces
  def initialize
    @workspaces = {
      # those are (sometimes) directly created by me and shoul appear at the
      # start of the menu, thus they are on top of this list
      dev: { number: 20 },
      notes: { class: %w[Zettlr Abricotine], number: 10 },
      conf: { number: 15 },
      test: { number: 17 },
      'dev-moves': { number: 21 },
      'dev-moves-mobile': { number: 22 },

      thunderbird: { number: 0, class: 'thunderbird' },
      signal: { number: 5, class: 'Signal' },
      skype: { class: 'Skype', number: 6 },
      teams: { class: 'Microsoft Teams - Preview', number: 7 },
      slack: { class: 'Slack', number: 8 },
      db: { number: 18, class: ['Studio 3T', 'Mysql-workbench-bin', 'SQLiteStudio', 'DBeaver'] },
      www: { class: 'qutebrowser', number: 28 },
      fox: { class: 'firefox', number: 30 },
      vnc: { class: 'Vncviewer', number: 34 },
      pass: { class: 'KeePassXC', number: 36 },
      tube: { class: 'Minitube', number: 38 },
      Xsane: { class: 'Xsane', number: 40 },
      xsane: { class: 'xsane', number: 45 },
      track: { class: 'Hamster', number: 47 },
      tasks: { class: 'abeluna', number: 50 },
      wine: { class: 'explorer.exe', number: 60 },
      dosbox: { class: 'dosbox', number: 70 },
      mediathek: { class: %w[mediathek-Main MediathekView], number: 80 },
      calibre: { class: 'calibre', number: 82 },
      weather: { class: 'Org.gnome.Weather', number: 86 },
      server: { number: 88 },
      blueman: { class: 'Blueman-manager', number: 90 },
      x3: { class: 'X3R_config', number: 92 },
      sr: { class: 'SimpleScreenRecorder', number: 99 }
    }
  end

  def get_workspace_name(key)
    "#{@workspaces[key][:number].to_s.rjust(2, '0')}_#{key}"
  end

  def print_rules
    rules = []
    @workspaces.each do |key, conf|
      next unless conf[:class]

      classes = conf[:class].is_a?(Array) ? conf[:class] : [conf[:class]]
      classes.each do |cls|
        workspace = get_workspace_name(key)
        rules.push(["[class=\"#{cls}\"]", workspace])
      end
    end
    max_criteria_length = rules.reduce(0) do |memo, rule|
      memo > rule[0].length ? memo : rule[0].length
    end
    rules.each do |rule|
      criteria = rule[0].ljust(max_criteria_length)
      puts "assign #{criteria} → #{rule[1]}"
    end
  end

  def workspace_list
    @workspaces.map do |key, _conf|
      get_workspace_name(key)
    end
  end

  def print_workspace_list
    puts workspace_list.join("\n")
  end

  def switcher
    workspace = ''
    Open3.popen3('rofi -dmenu') do |stdin, stdout|
      stdin.write(workspace_list.join("\n"))
      stdin.close
      workspace = stdout.read
    end
    `i3-msg move window to workspace #{workspace}`
  end
end

ws = I3Workspaces.new
case ARGV[0]
when 'rules'
  ws.print_rules
when 'switcher'
  ws.switcher
else
  ws.print_workspace_list
end
