#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
	db.execute('SELECT * FROM Barbers WHERE name=?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exists? db, barber
			db.execute 'INSERT INTO Barbers (name) VALUES (?)', [barber]
		end
	end
end

def get_db
	db = SQLite3::Database.new 'barbershop.db'
	db.results_as_hash = true
	return db
end

configure do
	db = get_db
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users" 
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
			"username" TEXT, 
			"phone" TEXT, 
			"datestamp" TEXT, 
			"barber" TEXT, 
			"color" TEXT
		)'

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Barbers" 
		(
			"id" INTEGER PRIMARY KEY AUTOINCREMENT, 
			"name" TEXT
		)'
	seed_db db, ['Jessie Pinkman', 'Walter White', 'Gus Fring', 'Mike Ehrmantraut']
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	@title_about = "О нас"
	erb :about
end

get '/visit' do
	erb :visit
end

get '/message' do
	erb :message
end

post '/visit' do
	@user_name = params[:user_name]
	@phone = params[:phone]
	@date_time = params[:date_time]
	@barbers = params[:barbers]
	@color = params[:color]

	hh = {  :user_name => 'Введите имя',
			:phone => 'Введите телефон',
			:date_time => 'Введите дату и время'}

	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")
	
	if @error != ''
		return erb :visit
		
	end

	db = get_db
	db.execute 'INSERT INTO 
	Users
	(
		username,
		phone,
		datestamp,
		barber,
		color
	)
	VALUES (?, ?, ?, ?, ?)', [@user_name, @phone, @date_time, @barbers, @color]

	erb "Дорогой #{@user_name}, вы записались #{@date_time} к парикмахеру #{@barbers} цвет волос: #{@color}"

	# f = File.open './public/users.txt', 'a'
	# f.write "User: #{@user_name}, Phone: #{@phone}, Date and time: #{@date_time}, Barbers: #{@barbers}"+"\n\r"
	# f.close

	# erb :message
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@your_email = params[:your_email]
	@your_textarea = params[:your_textarea]

	@title = "Thank you!"
	@message = "На ваш эмейл #{@your_email}, будет отправлен ответ"

	f = File.open './public/contacts.txt', 'a'
	f.write "Email: #{@your_email}, Text: #{@your_textarea}"+"\n\r"
	f.close

	# require 'pony'
	# Pony.mail(
	#    :name => params[:name],
	#   :mail => params[:mail],
	#   :body => params[:body],
	#   :to => 'a_lumbee@gmail.com',
	#   :subject => params[:name] + " has contacted you",
	#   :body => params[:message],
	#   :port => '587',
	#   :via => :smtp,
	#   :via_options => { 
	#     :address              => 'smtp.gmail.com', 
	#     :port                 => '587', 
	#     :enable_starttls_auto => true, 
	#     :user_name            => 'xxx', 
	#     :password             => 'xxxxxxx', 
	#     :authentication       => :plain, 
	#     :domain               => 'localhost.localdomain'
	#   })
	# redirect '/success' 

	erb :message
end

get '/showusers' do

  	db = get_db

  	@results = db.execute "SELECT * FROM Users order by id desc" 

	erb :showusers
end