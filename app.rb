require 'slim'
require 'sinatra'  
require 'SQLite3'
require 'BCrypt'
require 'byebug'
enable :sessions

get('/') do
    slim(:index)
end

get('/log') do
    slim(:log)
end

post('/log') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true
    result = db.execute("SELECT UserID, Username, Password FROM Users WHERE username = ?", params["name"])
    if result.length > 0 && BCrypt::Password.new(result.first["Password"]) == params["Password"]
        session[:name] = result.first["username"]
        session[:Id] = result.first["Id"]
        redirect('/log')
    else
        redirect('/')
    end
end

get('/create') do
    slim(:create)
end

post('/create') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true
    hashed_password = BCrypt::Password.create(params["password"])
    db.execute("INSERT INTO Users(Username, Password, Email) VALUES (?,?,?)",  params["username"], hashed_password, params["mail"])

    redirect('/') 
end

