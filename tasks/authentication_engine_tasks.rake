namespace :authentication_engine do
  desc "Sync extra files form authentication engine"
  task :sync do
    system "rsync -ruv vendor/plugins/authentication_engine/db/migrate db"
    system "rsync -ruv vendor/plugins/authentication_engine/public ."
    system "rsync -ruv vendor/plugins/authentication_engine/config/initializers config"
    system "rsync -ruv vendor/plugins/authentication_engine/config/authentication_config.yml config"
    # looks like rails doesn't pick up mailer templates, so sync them...
    system "rsync -ruv vendor/plugins/authentication_engine/app/views/notifier app/views"
  end
end