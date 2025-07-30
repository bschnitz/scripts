#!/usr/bin/env ruby

require 'sqlite3'
require 'fileutils'

# Datenbankpfad setzen
db_path = File.expand_path("~/wgames/game.db")
FileUtils.mkdir_p(File.dirname(db_path))
db = SQLite3::Database.new db_path

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    wine_prefix TEXT
  );
SQL

class Tools
  def add_prefix_dir(prefix_name)
    prefix = File.expand_path("~/data/free/games/prefixes/#{prefix_name}")
    FileUtils.mkdir_p(prefix)
    prefix
  end
end

def install_game(db, name, setup_exe)
  prefix = Tools.new.expand_path("~/data/free/games/prefixes/#{name}")
  setup_exe = File.expand_path(setup_exe)
  puts "Installiere Spiel '#{name}' mit Prefix '#{prefix}' und Setup '#{setup_exe}'..."
  system("WINEPREFIX=#{prefix} wine \"#{setup_exe}\"")
  db.execute("INSERT INTO games (name, wine_prefix) VALUES (?, ?)", [name, prefix])
  puts "Installation abgeschlossen."
end

def cdinstall_game(name, cd_path)
  prefix = Tools.new.expand_path("~/data/free/games/prefixes/#{name}")
  cd_path = File.expand_path(cd_path)
  puts "Starte Wine-Explorer mit CD-Pfad '#{cd_path}' und Prefix '#{prefix}'..."
  system("WINEPREFIX=#{prefix} winecfg")
  system("WINEPREFIX=#{prefix} wine explorer")
end

def list_games(db, filter = nil)
  query = "SELECT id, name, wine_prefix FROM games"
  params = []
  if filter
    query += " WHERE name LIKE ?"
    params << "%#{filter}%"
  end

  games = db.execute(query, params)
  games.each { |id, name, prefix| puts "[#{id}] #{name} - #{prefix}" }
end

def start_game(db, identifier)
  if identifier =~ /^\d+$/
    game = db.execute("SELECT wine_prefix FROM games WHERE id = ?", [identifier.to_i]).first
  else
    game = db.execute("SELECT wine_prefix FROM games WHERE name = ?", [identifier]).first
  end
  
  if game
    prefix = game.first
    game_dirs = [File.join(prefix, "drive_c/game"), File.join(prefix, "drive_c/GAME")]
    
    exe_files = []
    game_dirs.each do |dir|
      if Dir.exist?(dir)
        exe_files += Dir.glob(File.join(dir, "**", "*.exe"))
        exe_files += Dir.glob(File.join(dir, "**", "*.EXE"))
        exe_files += Dir.glob(File.join(dir, "**", "*.lnk"))
      end
    end
    
    if exe_files.empty?
      puts "Keine ausführbaren Dateien gefunden in #{game_dirs.join(' oder ')}."
      return
    end
    
    puts "Verfügbare .exe-Dateien:" 
    exe_files.each_with_index { |file, index| puts "[#{index}] #{File.basename(file)}" }
    print "Wähle eine Datei zum Starten (Nummer eingeben): "
    choice = STDIN.gets.to_i
    if choice >= 0 && choice < exe_files.size
      selected_exe = exe_files[choice]
      puts "Starte #{selected_exe}..."
      dir = File.dirname selected_exe
      exe = File.basename selected_exe
      Dir.chdir dir
      system("WINEPREFIX=#{prefix} wine \"#{exe}\"")
    else
      puts "Ungültige Auswahl."
    end
  else
    puts "Spiel '#{identifier}' nicht gefunden."
  end
end

command = ARGV.shift
case command
when 'install'
  install_game(db, ARGV[0], ARGV[1])
when 'cdinstall'
  cdinstall_game(ARGV[0], ARGV[1])
when 'list'
  list_games(db, ARGV[0])
when 'start'
  start_game(db, ARGV[0])
else
  puts "Befehle: install <name> <setup_exe>, cdinstall <name> <cd_path>, list [filter], start <name|id>"
end
