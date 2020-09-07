# frozen_string_literal: true

require 'pg'

class DatabasePersistence
  def initialize(logger) # sinatra logger object passed as an argument for logging
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL']) # connection for if we are using Heroku production environment
          else
            PG.connect(dbname: 'todos') # standard normal connection we've been doing in development
          end
    @logger = logger # see https://launchschool.com/lessons/421e2d1e/assignments/d7a23509
  end

  def disconnect
    @db.close # prevents us from exceeding Heroku database 20 connection limit. See: https://launchschool.com/lessons/421e2d1e/assignments/54681a23
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params) # the * splat operator in the parameter implementation 2 lines above turns `params` in this line into an array of such arguments
  end

  def find_list(id)
    sql = 'SELECT * from lists where id = $1' # the $1 here being the id argument passed in to this find_list(id) method
    result = query(sql, id) # takes the parameter id, and this array will be used to fill the sql query, in this case only $1
    tuple = result.first # we only need the first row
    list_id = tuple['id']
    todos = find_todos_for_list(list_id)
    { id: list_id, name: tuple['name'], todos: todos } # already was built in all_lists method in this file
  end

  def all_lists
    sql = 'SELECT * from lists' # note the ; is optional and is appended for you if you do not include it
    result = query(sql) # note our `query` method now handles logging too, see it's implementation
    result.map do |tuple| # take each record/row and conver them into a hash, each of which togther are returned in an array by .map
      list_id = tuple['id']
      todos = find_todos_for_list(list_id)
      { id: list_id, name: tuple['name'], todos: todos } # `todos` here being an array of hashes, each hash representing a todo
    end
  end

  def create_new_list(list_name)
    sql = 'INSERT INTO lists (name) VALUES ($1)' # implemented in assignment: https://launchschool.com/lessons/421e2d1e/assignments/0b9c3307
    query(sql, list_name)
  end

  def delete_list(list_id)
    query('DELETE FROM todos WHERE list_id = $1', list_id) # this is necessary since ON DELETE CASCADE constraint is not put on list_id in the todos table
    query('DELETE FROM lists WHERE id = $1', list_id) # after deleting todos in the todos table associated with this list's id, we can then delete the list itself
  end

  def update_list_name(list_id, new_name)
    sql = 'UPDATE lists SET name = $1 WHERE list_id = $2'
    query(sql, new_name, list_id)
  end

  def create_new_todo(list_id, todo_name) # adding a new todo item to a list
    sql = 'INSERT INTO todos (list_id, name) VALUES ($1, $2)' # note the $1, $2 order isn't the argument order in the line above, but the line below in the `query` method call
    query(sql, list_id, todo_name)
  end

  def delete_todo_from_list(list_id, todo_id)
    sql = 'DELETE FROM todos WHERE id = $1 AND list_id = $2'
    query(sql, todo_id, list_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    sql = 'UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3'
    query(sql, new_status, todo_id, list_id)
  end

  def mark_all_todos_as_completed(list_id)
    sql = 'UPDATE todos SET completed = true WHERE list_id = $1'
    query(sql, list_id)
  end

  private

  def find_todos_for_list(list_id) # see https://launchschool.com/lessons/421e2d1e/assignments/c7a670dc
    todo_sql = 'SELECT * FROM todos WHERE list_id = $1'
    todos_result = query(todo_sql, list_id)

    todos_result.map do |todo_tuple|
      { id: todo_tuple['id'].to_i, name: todo_tuple['name'], completed: todo_tuple['completed'] == 't' } # see https://launchschool.com/lessons/421e2d1e/assignments/c7a670dc
    end
 end
end
