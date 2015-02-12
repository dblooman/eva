module Eva
  class ContainerMetadata
    attr_accessor :container

    def initialize(container)
      @container = container
    end

    def name
      if container.info["Name"] || container.info["Names"]
        container_info = container.info
      else
        container_info = container.json
      end

      name = container_info["Name"]
      if container_info["Names"] && !container_info["Names"].empty?
        name = container_info["Names"].first
      end

      name.gsub("/", "").downcase
    end

    def info
      []
    end

    def status
      container.info["Status"]
    end

    def data
      container.json
    end

    def id
      container.id
    end

    def logs
      CGI.escapeHTML(container.logs(:stdout => 1, :tail => 20, :timestamps => 1))
    end
  end
end
