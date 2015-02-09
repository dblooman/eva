module Helpers
  class << self
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
  end
end
