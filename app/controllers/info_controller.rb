class InfoController < ApplicationController
  include Helpers

  get "/:id" do
    begin
      container = Docker::Container.get(params[:id])
      @container = Eva::ContainerMetadata.new(container)
    rescue Docker::Error::NotFoundError
      @errors << "Container not found"
    end
    erb :logs
  end
end
