#!/usr/bin/env ruby

class I3Workspaces
  def initialize
    @workspaces = {
      thunderbird: { class: 'Thunderbird', number: 0 },
      signal: { class: 'Signal', number: 5 },
      skype:  { class: 'Skype', number: 6 },
      teams: { class: 'Microsoft Teams - Preview', number: 7 },
      notes:  { class: ['Zettlr', 'Abricotine'], number: 10 },
      dev:    { number: 20 },
      mysql_wb: { class: 'Mysql-workbench-bin', number: 25 },
      www: { class: ['qutebrowser', 'firefox'], number: 30 },
      pass: { class: 'Keepassx', number: 35 },
      Xsane: { class: 'Xsane', number: 40 },
      xsane: { class: 'xsane', number: 45 },
      tasks: { class: 'abeluna', number: 50 },
      wine: { class: 'explorer.exe', number: 60 },
      dosbox: { class: 'dosbox', number: 70 },
      mediathek: { class: ['mediathek-Main', 'MediathekView'], number: 80 },
      calibre: { class: 'calibre', number: 82 },
      config: { number: 88 },
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

  def print_workspace_list()
    @workspaces.each do |key, conf|
      puts self.get_workspace_name(key)
    end
  end
end

ws = I3Workspaces.new
if ARGV[0] == 'rules' then
  ws.print_rules()
else
  ws.print_workspace_list()
end
