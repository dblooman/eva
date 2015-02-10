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
    rescue
      session[:errors] = ["There was a problem, please try again."]
    end
    redirect "/images"
  end
end
