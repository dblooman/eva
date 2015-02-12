require "./app/helpers/eva"

class ApplicationController < Sinatra::Base
  set :server, "thin"
  set :public_folder, File.expand_path("../../../", __FILE__)
  set :views, File.expand_path("../../views", __FILE__)
  set :bind, "0.0.0.0"
  set :docker_url, ENV["DOCKER_HOST"] || "unix:///var/run/docker.sock"

  enable :sessions

  use Rack::Session::Cookie, :expire_after => 1, :secret => "eva"

  Excon.defaults[:ssl_verify_peer] = false

  before do
    request.path_info.sub!(%r{/$}, "")

    @messages = session[:messages] || []
    @errors   = session[:errors] || []
    @info     = session[:info] || []
  end

  helpers do
    include Helpers
  end
end
