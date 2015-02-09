module Eva
  class Image
    class << self
      def create(image)
        payload = { "fromImage" => image }

        Docker::Image.create(payload)
      end
    end
  end
end
