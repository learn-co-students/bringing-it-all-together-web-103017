class Dog
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
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

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(hash)
    new_dog = self.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * from dogs where id = ?
    SQL

    self.new_from_db(DB[:conn].execute(sql, id).first)
  end

  def self.new_from_db(row)
    Dog.new(name:row[1],breed:row[2],id:row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs where name = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first

  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if dog.empty?
      dog = self.create(name: name, breed: breed)
    else
      dog_data = dog.first
      dog = self.new_from_db(dog_data)
    end
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? where id = ?
    SQL

    DB[:conn].execute(sql,self.name,self.breed, self.id)
    self
  end

end
