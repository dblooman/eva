require "sidekiq"
require "docker"

Excon.defaults[:ssl_verify_peer] = false

Sidekiq.configure_client do |config|
  config.redis = { :namespace => "x", :size => 1 }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => "x" }
end

class DockerWorkers
  include Sidekiq::Worker

  def perform(name)
    Docker::Image.create("fromImage" => name)
  end
end

class DockerRunner
  def self.pull(name)
    DockerWorkers.perform_async(name)
  end
end
