require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(hash) # can also be key: hash

    hash.each do |k, v|
      self.send("#{k}=", v) # equivalent to self.k = v
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save # WE NEED TO INSURE IF IT EXISTS NOT TO SAVE IT AGAIN
    if self.id # if the object has an id, just return the object
      return self
      #self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      # method that acts on an instance of the dog class
      # returns that very same instance of the dog class
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      return self
    end
    # binding.pry
  end

  def self.create(hash)
    self.new(hash).save
    # takes a hash
    # uses hash to create new dog
    # saves dog to the db using .save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    new_dog = DB[:conn].execute(sql, id)[0]
    new_dog_object = self.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2]) # where the effup occurs
    new_dog_object
    # binding.pry
    # takes in an id
    # query the db and select dog where dogs.id = id
  end

  def self.find_or_create_by(name:, breed:)
    # test whether it already exists
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL
    new_dog = DB[:conn].execute(sql, name, breed)[0]
    if new_dog
      self.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
    else
      # binding.pry
      self.create(name: name, breed: breed)
    end
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    # returns INSTANCE of dog from database that matches name given
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL
    test = self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    #the instance is self...we need to update it in the database
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
