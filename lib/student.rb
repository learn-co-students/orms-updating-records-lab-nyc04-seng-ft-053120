require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :id, :name, :grade

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    # creates students table with columns that match the attributes of our individual students: an id, the name, and the grade
    sql = "CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    # drops the students table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
    # This instance method inserts a new row into the database using the attributes of the given object. This method also assigns the id attribute of the object once the row has been inserted into the database.
    # if the project has been persisted, its id will not be nil, so in that case, update the the object's row
    if self.id
      self.update
    else
      sql = "INSERT INTO students (id, name, grade) VALUES (?, ?, ?)"
      DB[:conn].execute(sql, self.id, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    # This method updates the database row mapped to the given Student instance.
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    # This method creates a student with two attributes, name and grade, and saves it into the students table.
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    # This class method takes an argument of an array. When we call this method we will pass it the array that is the row returned from the database by the execution of a SQL query. We can anticipate that this array will contain three elements in this order: the id, name and grade of a student.

    # The .new_from_db method uses these three array elements to create a new Student object with these attributes.
    id = row[0]
    name = row[1]
    grade = row[2]
    new_student = self.new(id, name, grade)
  end

  def self.find_by_name(name)
    # This class method takes in an argument of a name. It queries the database table for a record that has a name of the name passed in as an argument. Then it uses the #new_from_db method to instantiate a Student object with the database row that the SQL query returns.

    sql = "SELECT * FROM students WHERE name = ?"
    DB[:conn].execute(sql, name).map { |row| self.new_from_db(row) }.first
  end
end
