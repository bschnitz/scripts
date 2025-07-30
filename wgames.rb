#!/usr/bin/env ruby

require 'sqlite3'
require 'fileutils'

# Datenbankpfad setzen
db_path = File.expand_path("~/wgames/game.db")
FileUtils.mkdir_p(File.dirname(db_path))
db = SQLite3::Database.new db_path

# Tabelle aktualisieren
begin
  db.execute("ALTER TABLE games ADD COLUMN game_dirs TEXT")
rescue SQLite3::SQLException
end
begin
  db.execute("ALTER TABLE games ADD COLUMN last_exe TEXT")
rescue SQLite3::SQLException
end

db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE,
    wine_prefix TEXT,
    game_dirs TEXT,
    last_exe TEXT
  );
SQL

class Tools
  def add_prefix_dir(prefix_name)
    prefix = File.expand_path("~/data/free/games/prefixes/#{prefix_name}")
    FileUtils.mkdir_p(prefix)
    prefix
  end
end

def install_game(db, name, setup_exe, game_dirs = nil)
  prefix = File.expand_path("~/data/free/games/prefixes/#{name}")
  setup_exe = File.expand_path(setup_exe)
  puts "Installiere Spiel '#{name}' mit Prefix '#{prefix}' und Setup '#{setup_exe}'..."
  system("WINEPREFIX=#{prefix} wine \"#{setup_exe}\"")
  db.execute("INSERT INTO games (name, wine_prefix, game_dirs) VALUES (?, ?, ?)", [name, prefix, game_dirs])
  puts "Installation abgeschlossen."
end

def cdinstall_game(db, name, cd_path, game_dirs = nil)
  prefix = File.expand_path("~/data/free/games/prefixes/#{name}")
  cd_path = File.expand_path(cd_path)
  puts "Starte Wine-Explorer mit CD-Pfad '#{cd_path}' und Prefix '#{prefix}'..."
  system("WINEPREFIX=#{prefix} winecfg")
  system("WINEPREFIX=#{prefix} wine explorer")
  db.execute("INSERT INTO games (name, wine_prefix, game_dirs) VALUES (?, ?, ?) ON CONFLICT(name) DO UPDATE SET game_dirs=excluded.game_dirs", [name, prefix, game_dirs])
end

def list_games(db, filter = nil)
  query = "SELECT id, name, wine_prefix, game_dirs, last_exe FROM games"
  params = []
  if filter
    query += " WHERE name LIKE ?"
    params << "%#{filter}%"
  end

  games = db.execute(query, params)
  games.each { |id, name, prefix, game_dirs, last_exe| puts "[#{id}] #{name} - #{prefix} | game_dirs: #{game_dirs || 'N/A'} | last_exe: #{last_exe || 'N/A'}" }
end

def start_game(db, identifier)
  if identifier =~ /^\d+$/
    game = db.execute("SELECT wine_prefix, game_dirs FROM games WHERE id = ?", [identifier.to_i]).first
  else
    game = db.execute("SELECT wine_prefix, game_dirs FROM games WHERE name = ?", [identifier]).first
  end

  if game
    prefix, game_dirs = game
    game_dirs = game_dirs ? game_dirs.split(',') : []
    game_dirs += ["drive_c/game", "drive_c/GAME"] if game_dirs.empty?
    
    exe_files = []
    game_dirs.each do |dir|
      full_path = File.join(prefix, dir)
      if Dir.exist?(full_path)
        exe_files += Dir.glob(File.join(full_path, "**", "*.exe"))
        exe_files += Dir.glob(File.join(full_path, "**", "*.EXE"))
        exe_files += Dir.glob(File.join(full_path, "**", "*.lnk"))
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
      db.execute("UPDATE games SET last_exe = ? WHERE wine_prefix = ?", [selected_exe.sub(prefix + '/', ''), prefix])
    else
      puts "Ungültige Auswahl."
    end
  else
    puts "Spiel '#{identifier}' nicht gefunden."
  end
end

def last_game(db, identifier)
  game = db.execute("SELECT wine_prefix, last_exe FROM games WHERE name = ? OR id = ?", [identifier, identifier.to_i]).first
  
  if game
    prefix, last_exe = game
    if last_exe
      full_path = File.join(prefix, last_exe)
      puts "Starte #{full_path}..."
      dir = File.dirname full_path
      exe = File.basename full_path
      Dir.chdir dir
      system("WINEPREFIX=#{prefix} wine \"#{exe}\"")
    else
      puts "Kein zuletzt gestartetes Spiel für '#{identifier}' gespeichert."
    end
  else
    puts "Spiel '#{identifier}' nicht gefunden."
  end
end

command = ARGV.shift
case command
when 'install'
  install_game(db, ARGV[0], ARGV[1], ARGV[2])
when 'cdinstall'
  cdinstall_game(db, ARGV[0], ARGV[1], ARGV[2])
when 'list'
  list_games(db, ARGV[0])
when 'start'
  start_game(db, ARGV[0])
when 'last'
  last_game(db, ARGV[0])
else
  puts "Befehle: install <name> <setup_exe> [game_dirs], cdinstall <name> <cd_path> [game_dirs], list [filter], start <name|id>, last <name|id>"
end
