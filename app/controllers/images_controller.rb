class ImagesController < ApplicationController
  get "/" do
    @images = Docker::Image.all.map do |container|
      container
    end.compact
    erb :images
  end

  get "/update/*" do
    name = params[:splat].first

    begin
      DockerRunner.pull(name)
      session[:messages] = ["Image Updated"]
    rescue
      session[:errors] = ["There was a problem, please try again."]
    end
    redirect "/images"
  end

  get "/delete/*" do
    name = params[:splat].first

    begin
      DockerRunner.destroy(name)
      session[:messages] = ["Image Destroyed"]
    rescue
      session[:errors] = ["There was a problem, please try again."]
    end
    redirect "/images"
  end
end
