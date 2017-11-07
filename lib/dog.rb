require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(input_hash)
    @name = input_hash[:name]
    @breed = input_hash[:breed]
    @id = input_hash[:id]
  end


  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)

    new_dog = self.new({id: row[0], name: row[1], breed:row[2]})
    new_dog
  end

  def self.find_by_name(input)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, input).flatten
     #binding.pry
    Dog.new_from_db(row)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql, id).flatten)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
    self

  end


  def self.create(input_hash)
    new_dog = self.new(input_hash)
    new_dog.save
    new_dog
  end


  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs
        (name, breed)
        VALUES
        (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

    def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
      SQL
      dog_row = DB[:conn].execute(sql, name, breed).flatten
      if dog_row.empty?
        self.create({name: name, breed: breed})
      else
        self.new_from_db(dog_row)
      end
    end









### ID setter ###
  def id=(id)
    if id
      @id = id
    else
      @id = nil
    end
  end








end # --> end Dog class
