#simplest ruby program to read from arduino serial, 
#using the SerialPort gem
#(http://rubygems.org/gems/serialport)

require 'rubygems'
require "sqlite3"
require 'sinatra'
require 'json'

script_dir = File.dirname(File.expand_path(__FILE__))
#load script_dir + "/buttons.rb"

db = SQLite3::Database.new "happiness.db"
# db 

# Create a database
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS happiness (
    time TIMESTAMP DEFAULT (datetime('now','localtime')),
    location INT,
    sad INT,
    happy INT
  );
SQL

#Thread.new(){
#	read_serial()
#}


post '/readings' do
	if params.has_key?("happy") and params.has_key?("sad") and params.has_key?("location")
		db.execute("insert 	into happiness(location, happy, sad) values( ?, ?, ? )", 
			params[:location], params[:happy], params[:sad])
		return [200, "saved"]
	else
		return [400, "required post params: happy, sad, location"]
	end
end

get '/' do
	return "<a href='/readings'>Readings</a>"
end

get '/readings' do
    locations = {}
	db.execute("select location, avg(happy), avg(sad) from happiness group by location ORDER BY location ASC") do |row|
    	locations[row[0]] = {'happy_avg' => row[1], 'sad_avg' => row[2]}
  	end

	[1,5,15].each do |mins|
		db.execute("select location, avg(happy), avg(sad) from happiness where time >= datetime('now', '-#{mins} minutes') group by location;") do |row|
			locations[row[0]]["happy_#{mins}min_avg"] = row[1];
			locations[row[0]]["sad_#{mins}min_avg"] = row[2];
		end
	end	

	return [200, {'Content-type' => 'application/json'}, JSON.generate(locations)]
end
