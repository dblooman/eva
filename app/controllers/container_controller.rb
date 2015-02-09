class ContainerController < ApplicationController
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
end
