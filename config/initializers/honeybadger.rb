Honeybadger.configure do |config|
  config_file = begin
                  YAML.load(File.read(Rails.root.join("config/honeybadger.yml")))
                rescue Errno::ENOENT => e
                  {}
                end
  config.api_key = config_file.fetch(Rails.env, {}).symbolize_keys[:api_key]
end
