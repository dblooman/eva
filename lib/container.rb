module Eva
  class Container
    attr_accessor :name, :image, :command

    def initialize(options)
      @name = options[:name]
      @image = options[:image]
      @command = options[:command]
    end

    def container
      Docker::Container.create(
        "name"  => name,
        "Image" => image,
        "Cmd"   => command
       )
    end

    def start
      container.start
    end
  end
end
