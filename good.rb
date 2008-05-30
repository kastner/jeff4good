require 'rubygems'
require 'sinatra'
require 'activerecord'

Dir["models/*"].each { |m| require m.gsub(/.rb$/,'') }

before do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.establish_connection(
    :adapter => "sqlite3", :database => "db.sqlite3"
  )
  
  # always send utf-8
  header "Content-Type" => "text/html; charset=utf-8"
  
  # set css body id
  @body_id = "home"
end
 
get "/" do
  @stuffs = Stuff.find(:all)
  total_pledged = Stuff.sum('worth', :conditions => "pledged_to IS NOT NULL")
  @percent = ((total_pledged || 0) / 10_000) * 100
  erb :index
end

post "/" do
  @stuff = Stuff.new(
    :email => params[:email], 
    :thing => params[:thing], 
    :worth => params[:worth]
  )
  @stuff.save
  redirect "/"
end

put "/pledge/:id" do
  @stuff = Stuff.find(params[:id])
  @stuff.update_attributes(
    :pledged_to => params[:email], 
    :pledged_at => Time.now
  )
  redirect "/"
end
