namespace :authentication_engine do
  desc "Sync extra files form authentication engine"
  task :sync do
    system "rsync -ruv vendor/plugins/authentication_engine/db/migrate db"
    system "rsync -ruv vendor/plugins/authentication_engine/public ."
    system "rsync -ruv vendor/plugins/authentication_engine/config/initializers config"
    system "rsync -ruv vendor/plugins/authentication_engine/config/notifier.yml config"
    system "rsync -rbv vendor/plugins/authentication_engine/config/locales config"
    system "rsync -ruv vendor/plugins/authentication_engine/app/helpers/layout_helper.rb app/helpers"
    system "rsync -rbv vendor/plugins/authentication_engine/app/helpers/application_helper.rb app/helpers"
    system "rsync -rbv vendor/plugins/authentication_engine/app/views/layouts/application.html.erb app/views/layouts"
  end
end