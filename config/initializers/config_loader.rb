config = File.read(Rails.root.join('config', 'authentication_engine.yml'))
REGISTRATION = YAML.load(config)[RAILS_ENV]['registration'].symbolize_keys
ACTIVATION = YAML.load(config)[RAILS_ENV]['activation'].symbolize_keys
SIGNUP = YAML.load(config)[RAILS_ENV]['signup'].symbolize_keys
ADMIN = YAML.load(config)[RAILS_ENV]['admin'].symbolize_keys
NOTIFIER = YAML.load(config)[RAILS_ENV]['notifier'].symbolize_keys