require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
    #binding.pry
  end

  def self.create_table

  end

  def self.drop_table
    DB[:conn].execute('drop table dogs')
  end

  def save
    #binding.pry
    DB[:conn].execute("insert into dogs(name, breed) values ('#{self.name}', '#{self.breed}')")
    @id = DB[:conn].execute("select last_insert_rowid() from dogs where name='#{self.name}'").flatten[0]
    self
  end

  def self.create(name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save
  end

  def self.find_by_id(id)
    new_id = DB[:conn].execute("select * from dogs where id = #{id}").flatten
    dog = Dog.new(name: new_id[1], breed: new_id[2], id: new_id[0])
    dog
  #  binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    #dog = Dog.new(name: name, breed: breed)
    #binding.pry
    row = DB[:conn].execute("select * from dogs where name='#{name}' AND breed='#{breed}'").flatten
    if row == []
      #create dog
      Dog.create(name: name, breed: breed)
    else
      #return dog
      Dog.new(name: row[1], breed: row[2], id: row[0])
      # binding.pry
    end
    #binding.pry
  end

  def self.new_from_db(row)
    Dog.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("select * from dogs where name = '#{name}'").flatten
    Dog.new_from_db(row)
  end

  def update
    DB[:conn].execute("update dogs set name='#{self.name}', breed='#{self.breed}' where id=#{self.id}")
  end
end
