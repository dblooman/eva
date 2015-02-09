class IndexController < ApplicationController
  include Helpers

  get "/" do
    @containers = Docker::Container.all.map do |container|
      Eva::ContainerMetadata.new(container)
    end.compact

    erb :index
  end
end
