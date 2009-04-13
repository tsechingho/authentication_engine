if config.respond_to?(:gems)
  config.gem 'authlogic', :lib => 'authlogic', :version => '2.0.9', :source => "http://gems.github.com"
else
  begin
    require 'authlogic'
  rescue LoadError
    begin
      gem 'authlogic', '2.0.9'
    rescue Gem::LoadError
      puts "Install the authlogic gem to enable authentication support"
    end
  end
end

require File.dirname(__FILE__) + '/lib/authentication_engine'

