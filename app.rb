require 'sinatra'
require 'sinatra/contrib'
require 'faraday'

set :server, 'thin'
set :public_folder, File.expand_path('../', __FILE__)
set :views, File.expand_path('../views', __FILE__)
set :bind, '0.0.0.0'

get '/' do
  @data = 'hello world'

  erb :default
end
