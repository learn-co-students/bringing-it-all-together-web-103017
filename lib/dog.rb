require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash)
    hash.each do |key, value|
      self.send(("#{key}="), value)
    end

  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
     SQL

    DB[:conn].execute(sql)

  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      return self
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
    end
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id).first
    Dog.new_from_db(row)
  end

  def self.new_from_db(row)
    dog_hash = {}
    dog_hash[:id] = row[0]
    dog_hash[:name] = row[1]
    dog_hash[:breed] = row[2]
    Dog.create(dog_hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name).first
    Dog.new_from_db(row)
  end

  def self.find_or_create_by(hash)
    dog_obj = self.find_by_name(hash[:name])
     if dog_obj && dog_obj.breed == hash[:breed]
      return dog_obj
     else
      self.create(hash)
     end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
