
# an instance of the SessionPersistance class is used to set equal to the @storage instance variable above in `before`
class SessionPersistence
  def initialize(session)
    @session = session # pass in the session whenever we created a new SessionPersistence object, setting session to @session
    @session[:lists] ||= [] # moved from the `before` block in 175 to here, set a :lists key equal to empty array
  end

  def find_list(id)
    @session[:lists].find {|list| list[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def create_new_list(list_name)
    id = next_element_id(@session[:lists]) # for assigning an :id to a list, a new feature at this point, Lesson 6: https://launchschool.com/lessons/2c69904e/assignments/a8c93890
    @session[:lists] << { id: id, name: list_name, todos: [] } # remember in our form the <input> tag had a `name` of "list_name", so this is the key, and the value is whatever data we submitted if any, not there yet at this point, and note "list_name" can simply be treated as a symbol by sinatra, so :list_name in params hash
  end

  def delete_list(list_id)
    @session[:lists].reject! {|list| list[:id] == list_id } # remove the list - which is a hash itself, from the session array. refactored in lesson 6 to use Array#reject! and an actual id not based on index, for the list: https://launchschool.com/lessons/2c69904e/assignments/a8c93890
  end

  def update_list_name(list_id, new_name)
    list = find_list(list_id)
    list[:name] = new_name
  end

  def create_new_todo(list_id, todo_name) # adding a new todo item to a list
    list = find_list(list_id)
    id = next_element_id(list[:todos]) # assign an id to the new todo item, Lesson 6 assignment: https://launchschool.com/lessons/9230c94c/assignments/046ee3e0, refactored to general method for lists and ids in next assignment: https://launchschool.com/lessons/2c69904e/assignments/a8c93890
    list[:todos] << { id: id, name: todo_name, completed: false } # params[:todo] is the submitted text taken from form submission at the list.erb page submit form for a todo item, which is named "todo"
  end

  def delete_todo_from_list(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].reject! {|todo| todo[:id] == todo_id }  # updated Lesson 6, for any existing todo item with an id equal to todo_id `:id` from the url params, delete from todos with Array#reject!, https://launchschool.com/lessons/2c69904e/assignments/af479b47
  end

  def update_todo_status(list_id, todo_id, new_status)
    list = find_list(list_id)
    todo =  list[:todos].find {|t| t[:id] == todo_id } # refactored in lesson 6 assignment https://launchschool.com/lessons/2c69904e/assignments/af479b47
    todo[:completed] = new_status
  end

  def mark_all_todos_as_completed(list_id)
    list = find_list(list_id)
    list[:todos].each { |todo| todo[:completed] = true }
  end

  private 

  def next_element_id(elements) # for assigning a next available id for either a todo list itself or a todo item.  Was called `next_todo_id` in previous assignment, refactored in this new lesson 6 assignment: https://launchschool.com/lessons/2c69904e/assignments/a8c93890
    max = elements.map { |element| element[:id] }.max || 0 # the `|| 0` handles case of making the first todo item, fro which [].max returns nil, so nil || 0 return 0 and we avoid the nil + 1 error on next line
    max + 1 # || 0 in above line prevents nil + 1 error in case array is emtpy and [].max returns nil, so the || 0 will execute and max = 0 in that case.  So it gets the max id of an existing list or todo item id set(depending on if this is called for a list or a todo item), and then adds 1.  This return value is set as the id for any new list or todo item
  end
end