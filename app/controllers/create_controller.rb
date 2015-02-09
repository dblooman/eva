class CreateController < ApplicationController
  get "/" do
    erb :create
  end

  post "/" do
    begin
      pull_image(params[:image])
      Helpers.catch_not_found { Eva::Image.create(params[:image]) }
      container = Eva::Create.new(params)
      container.start
    rescue => e
      halt(409, { :error => e.message }.to_json)
    end
    redirect "/"
  end
end
