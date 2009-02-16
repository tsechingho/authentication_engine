raw_config = File.read(RAILS_ROOT + "/config/authentication_config.yml")
AUTHENTICATION_CONFIG = YAML.load(raw_config)[RAILS_ENV].symbolize_keys
