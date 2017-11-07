require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
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
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if self.id
      self.update
      self
    else
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
       DB[:conn].execute(sql, self.name, self.breed)
       @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
       self
     end
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    dog_row = DB[:conn].execute("SELECT * FROM dogs WHERE id = #{id} LIMIT 1")[0]

    new_dog = Dog.new_from_db(dog_row)
    new_dog
  end

  def self.new_from_db(row)
    result = Hash.new
    result[:name] = row[1]
    result[:breed] = row[2]
    result[:id] = row[0]

    new_dog = Dog.new(result)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL

    dog_row = DB[:conn].execute(sql, name)[0]

    new_dog = Dog.new_from_db(dog_row)
    new_dog
  end 

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end