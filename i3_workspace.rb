#!/usr/bin/env ruby

require 'open3'

class I3Workspaces
  def initialize
    @workspaces = {
      dev:    { number: 20 },
      notes:  { class: ['Zettlr', 'Abricotine'], number: 10 },
      conf: { number: 15 },

      thunderbird: { class: 'Thunderbird', number: 0 },
      signal: { class: 'Signal', number: 5 },
      skype:  { class: 'Skype', number: 6 },
      teams: { class: 'Microsoft Teams - Preview', number: 7 },
      sql: { class: 'Mysql-workbench-bin', number: 32 },
      www: { class: 'qutebrowser', number: 28 },
      fox: { class: 'firefox', number: 30 },
      tube: { class: 'Minitube', number: 32 },
      pass: { class: 'KeePassXC', number: 35 },
      Xsane: { class: 'Xsane', number: 40 },
      xsane: { class: 'xsane', number: 45 },
      tasks: { class: 'abeluna', number: 50 },
      wine: { class: 'explorer.exe', number: 60 },
      dosbox: { class: 'dosbox', number: 70 },
      mediathek: { class: ['mediathek-Main', 'MediathekView'], number: 80 },
      calibre: { class: 'calibre', number: 82 },
      server: { number: 88 },
      blueman: { class: 'Blueman-manager', number: 90 },
      x3: { class: 'X3R_config', number: 92 },
    }
  end

  def get_workspace_name(key)
    "#{@workspaces[key][:number].to_s.rjust(2, '0')}_#{key}"
  end

  def print_rules()
    rules = []
    @workspaces.each do |key, conf|
      next unless conf[:class]

      classes = conf[:class].is_a?(Array) ? conf[:class] : [conf[:class]]
      classes.each do |cls|
        workspace = self.get_workspace_name(key)
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

  def get_workspace_list()
    @workspaces.map do |key, conf|
      self.get_workspace_name(key)
    end
  end

  def print_workspace_list()
    puts self.get_workspace_list.join("\n")
  end

  def switcher()
    workspace = ''
    Open3.popen3('rofi -dmenu') do |stdin, stdout|
      stdin.write(self.get_workspace_list.join("\n"))
      stdin.close
      workspace = stdout.read
    end
    `i3-msg move window to workspace #{workspace}`
  end
end

ws = I3Workspaces.new
case ARGV[0]
when 'rules'
  ws.print_rules()
when 'switcher'
  ws.switcher
else
  ws.print_workspace_list()
end
