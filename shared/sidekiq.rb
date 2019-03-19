def sidekiq
  copy_file 'config/sidekiq.yml'
  run "mkdir -p tmp/pids"
  run "touch tmp/pids/sidekiq.pid"
  gsub_file('config/sidekiq.yml', /%application_name%/, application_name)
end

sidekiq
