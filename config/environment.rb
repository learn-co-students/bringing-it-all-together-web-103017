require 'sqlite3'
require_relative '../lib/dog'

# DB = {}
DB = {:conn => SQLite3::Database.new("db/dogs.db")}
# DB[:conn] = SQLite3::Database.new('db/dogs.db')

DB[:conn].results_as_hash = true
