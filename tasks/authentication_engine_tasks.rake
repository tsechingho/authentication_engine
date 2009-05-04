$LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')

namespace :authentication_engine do
  plugin_path = "vendor/plugins/authentication_engine"
  
  desc "Sync extra files form authentication engine"
  task :sync do
    system "rsync -rbv #{plugin_path}/app/controllers/application_controller.rb app/controllers"
    system "rsync -rbv #{plugin_path}/app/helpers/application_helper.rb app/helpers"
    system "rsync -ruv #{plugin_path}/app/helpers/layout_helper.rb app/helpers"
    system "rsync -rbv #{plugin_path}/app/views/layouts/application.html.erb app/views/layouts"
    system "rsync -ruv #{plugin_path}/config/authentication_engine.yml config"
    system "rsync -rbv #{plugin_path}/config/environments config"
    system "rsync -ruv #{plugin_path}/config/initializers config"
    system "rsync -rbv #{plugin_path}/config/locales config"
    system "rsync -ruv #{plugin_path}/db/migrate db"
    system "rsync -ruv #{plugin_path}/public ."
  end

  begin
    require 'cucumber/rake/task'

    Cucumber::Rake::Task.new(:features, "Run Features of authentication_engine with Cucumber") do |t|
      t.cucumber_opts = "--format pretty"
      t.feature_pattern = "#{plugin_path}/features/**/*.feature"
      t.step_pattern = "#{plugin_path}/features/**/*.rb"
    end
    task :features => 'db:test:prepare'
  rescue LoadError
    desc 'Cucumber rake task not available'
    task :features do
      abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
    end
  end
end