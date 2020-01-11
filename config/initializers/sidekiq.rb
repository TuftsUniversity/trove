unless Rails.env.development? || Rails.env.test?
  REDIS_CONFIG = YAML.safe_load(File.open(Rails.root.join('config', 'redis.yml'))).symbolize_keys
  conf = REDIS_CONFIG[Rails.env.to_sym].symbolize_keys

  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://:#{conf[:password]}@#{conf[:host]}:#{conf[:port]}" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://:#{conf[:password]}@#{conf[:host]}:#{conf[:port]}" }
  end
end
