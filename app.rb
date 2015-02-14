require "sinatra"
require "sinatra/contrib"
require "sinatra/namespace"
require "sinatra/config_file"
require "sinatra/namespace"
require "docker"
require "filesize"
require "eventmachine"
require "sinatra/base"
require "thin"
require "./helpers/eva"
Dir.glob("./lib/*.rb").each { |file| require file }

def run(opts)
  EM.run do
    server  = opts[:server] || "thin"
    host    = opts[:host]   || "0.0.0.0"
    port    = opts[:port]   || "3000"
    web_app = opts[:app]

    dispatch = Rack::Builder.app do
      map "/" do
        run web_app
      end
    end

    unless %w(thin hatetepe goliath).include? server
      fail "Need an EM webserver, but #{server} isn't"
    end

    Rack::Server.start(:app    => dispatch,
                       :server => server,
                       :Host   => host,
                       :Port   => port)
  end
end

class EvaApp < Sinatra::Base
  set :public_folder, File.expand_path("../", __FILE__)
  set :views, File.expand_path("../views", __FILE__)
  set :bind, "0.0.0.0"
  set :docker_url, ENV["DOCKER_HOST"] || "unix:///var/run/docker.sock"

  enable :sessions

  use Rack::Session::Cookie, :expire_after => 1, :secret => "eva"

  Excon.defaults[:ssl_verify_peer] = false

  configure do
    set :threaded, false
  end

  before do
    request.path_info.sub!(%r{/$}, "")

    @messages = session[:messages] || []
    @errors   = session[:errors] || []
    @info     = session[:info] || []
  end

  helpers do
    include Helpers
  end

  get "/" do
    @containers = Docker::Container.all.map do |container|
      Eva::ContainerMetadata.new(container)
    end.compact

    erb :index
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

  get "/images/update/*" do
    name = params[:splat].first

    @create_output = ""

    block = proc do |chunk|
      create_output << chunk
    end

    create_image = proc do
      begin
        Docker::Image.create("fromImage" => name, &block)
      rescue Docker::Error::ArgumentError, Docker::Error::NotFoundError, Excon::Errors::Timeout, Excon::Errors::SocketError
        session[:errors] = ["There was a problem, please try again."]
      end
    end

    EM.defer(create_image)
    session[:messages] = ["Image is updating"]
    redirect "/images"
  end

  get "/images/delete/*" do
    name = params[:splat].first

    begin
      image = Docker::Image.get(name)
      image.remove(:force => true)
      session[:messages] = ["Image Destroyed"]
    rescue Docker::Error::ArgumentError, Docker::Error::NotFoundError, Excon::Errors::Timeout, Excon::Errors::SocketError
      session[:errors] = ["There was a problem, please try again."]
    end
    redirect "/images"
  end

  get "/info/:id" do
    begin
      container = Docker::Container.get(params[:id])
      @container = Eva::ContainerMetadata.new(container)
    rescue Docker::Error::ArgumentError, Docker::Error::NotFoundError, Excon::Errors::Timeout, Excon::Errors::SocketError
      @errors << "Container not found"
    end
    erb :logs
  end

  get "/container/restart/:id" do
    id = params[:id]

    begin
      container = Docker::Container.get id
      container.restart
      session[:messages] = ["Container restarted"]
    rescue Docker::Error::ArgumentError, Docker::Error::NotFoundError, Excon::Errors::Timeout, Excon::Errors::SocketError
      session[:errors] = ["There was a problem, please try again."]
    end
    redirect "/container"
  end

  get "/container/destroy/:id" do
    id = params[:id]

    begin
      container = Docker::Container.get id
      container.kill
      container.delete(:force => true)
      session[:messages] = ["Container #{id} has been destroyed"]
    rescue Docker::Error::ArgumentError, Docker::Error::NotFoundError, Excon::Errors::Timeout, Excon::Errors::SocketError
      session[:errors] = ["There was a problem, please try again."]
    end
    redirect "/"
  end
end

# start the application
run :app => EvaApp.new
