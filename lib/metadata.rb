module Eva
  class ContainerMetadata
    attr_accessor :container

    def initialize(container)
      @container = container
    end

    def name
      if @container.info["Name"] || @container.info["Names"]
        container_info = @container.info
      else
        container_info = @container.json
      end

      name = container_info["Name"]
      if container_info["Names"] && !container_info["Names"].empty?
        name = container_info["Names"].first
      end

      name.gsub("/", "").downcase
    end

    def info
      []
      # info_conf_path = @config["run_script_path"] + "#{name}/info.json"
      # JSON.parse(File.read(info_conf_path)) if File.exist? info_conf_path
    end

    def status
      @container.info["Status"]
    end

    def id
      @container.id
    end

    def logs
      CGI.escapeHTML(@container.logs(:stdout => 1))
    end

    def to_hash
      {
        :name   => name,
        :links  => {
          :mobile  => mobile_link,
          :desktop => desktop_link
        },
        :info   => info,
        :status => status,
        :id     => id
      }
    end
  end
end
