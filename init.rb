if config.respond_to?(:gems)
  config.gem 'authlogic', :lib => 'authlogic', :version => '2.0.11', :source => "http://gems.github.com"
  config.gem 'authlogic-oid', :lib => 'authlogic_openid', :version => '>=1.0.3', :source => "http://gems.github.com"
else
  begin
    require 'authlogic'
    require 'authlogic_openid'
  rescue LoadError
    begin
      gem 'authlogic', '2.0.11'
      gem 'authlogic-oid', '1.0.3'
    rescue Gem::LoadError
      puts "Install the authlogic gem and authlogic_oid gem to enable authentication support"
    end
  end
end

require File.dirname(__FILE__) + '/lib/authentication_engine'

