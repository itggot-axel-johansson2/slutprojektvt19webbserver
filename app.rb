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
    result = db.execute("SELECT UserID, Username, Password FROM Users WHERE Username = ?", params["username"])
    if result.length > 0 && BCrypt::Password.new(result.first["Password"]) == params["password"]
        session[:name] = result.first["username"]
        session[:UserId] = result.first["UserId"]
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


get('/profil') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true

    if session[:Id] == nil
        redirect('/')
    else
        result =  db.execute("SELECT Text, Images FROM profile WHERE UserId = ?", session[:Id])
        
        slim(:profile, locals:{
            posts: result
        })
    end
end

get('/write') do
    slim(:write)
end

post('/write') do
    db = SQLite3::Database.new("db/blogg.db")
    db.results_as_hash = true

    db.execute("INSERT INTO inlägg(Text, Images, UserID) VALUES(?, ?, ?)" params["text"], params["image"], session[:id])

    redirect('/profil')
end