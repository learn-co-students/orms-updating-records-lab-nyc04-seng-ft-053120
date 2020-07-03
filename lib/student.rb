require_relative "../config/environment.rb"
require 'pry'
class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name,grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql_code= "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql_code)
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def save
    if self.id
      self.update 
    else
      sql_save = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql_save, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    # create an instance with the info given
    student = Student.new(name, grade)
    # save checks if they exit/if now inserts into the table + assigns the id to the instances id
    student.save 
    student
  end

  def self.new_from_db(row)
    s1 = self.create(row[1], row[2])
    s1
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE students.name = ?
    SQL
    x = DB[:conn].execute(sql, name).flatten

    Student.new(x[1],x[2],x[0])
    
  end

end
