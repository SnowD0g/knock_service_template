def sidekiq
  copy_file 'config/sidekiq.yml'
  directory "tmp/pids", force: true
  run "touch tmp/pids/sidekiq.pid"
  gsub_file('config/sidekiq.yml', /%application_name%/, application_name)
end

sidekiq
