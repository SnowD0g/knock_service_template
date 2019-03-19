def sidekiq
  copy_file 'config/sidekiq.yml'
  run "mkdir -p tmp/pids"
  run "touch tmp/pids/sidekiq.pid"
  gsub_file('config/sidekiq.yml', /%application_name%/, application_name)
  initializer 'sidekiq.rb', "Sidekiq.configure_server { |config| config.redis = { url: 'redis://localhost:32769' } }"
end

sidekiq
