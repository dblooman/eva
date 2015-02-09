require "sinatra"
require "sinatra/contrib"
require "sinatra/namespace"
require "sinatra/config_file"
require "sinatra/namespace"
require "docker"
require 'filesize'
require 'eventmachine'

Dir.glob("./lib/*.rb").each { |file| require file }

set :server, "thin"
set :public_folder, File.expand_path("../", __FILE__)
set :views, File.expand_path("../views", __FILE__)
set :bind, "0.0.0.0"
set :docker_url, ENV["DOCKER_HOST"] || "unix:///var/run/docker.sock"
Excon.defaults[:ssl_verify_peer] = false

before do
  request.path_info.sub!(%r{/$}, "")

  @messages = session[:messages] || []
  @errors   = session[:errors] || []
  @info     = session[:info] || []
end

get "/" do
  @containers = Docker::Container.all.map do |container|
    Eva::ContainerMetadata.new(container)
  end.compact

  erb :index
end

get "/create" do

  erb :create
end

post "/create" do
  begin
    p params[:image]
    pull_image(params[:image])
    container = catch_not_found { Eva::Image.create(params[:image]) }
    container = Eva::Create.new(params)
    container.start
  rescue => e
    halt(409, {error: e.message}.to_json)
  end
  redirect '/'
end

get "/restart/:id" do

  id = params[:id]

  begin
    container = Docker::Container.get id
    container.restart
  rescue
    session[:errors] = ["There was a problem, please try again."]
  end
  redirect "/"
end

get "/destroy/:id" do
  id = params[:id]

  begin
    container = Docker::Container.get id
    container.kill
    container.delete(:force => true)
    session[:messages] = ["Container #{id} has been destroyed"]
  rescue
    session[:errors] = ["There was a problem, please try again."]
  end
  redirect "/"
end

get "/info/:id" do
  begin
    container = Docker::Container.get(params[:id])
    @container = Eva::ContainerMetadata.new(container)
  rescue Docker::Error::NotFoundError
    @errors << "Container not found"
  end
  erb :logs
end

get "/images" do
  @images = Docker::Image.all.map do |container|
    container
  end.compact
  erb :images
end

get "/update/*" do
  begin
    Docker::Image.create("fromImage" => "#{params[:splat].first}")
  rescue
    p 'ph'
    session[:errors] = ["There was a problem, please try again."]
  end
  redirect "/images"
end


def pull_image(tag)
  catch_not_found { Eva::Image.create(tag) }
rescue Docker::Error::ArgumentError, Docker::Error::ServerError
  puts "Image not found in registry"
end

def catch_not_found(&_block)
  yield
rescue Docker::Error::NotFoundError
  puts "Image not found locally"
  halt 404
end
