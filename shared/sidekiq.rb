def sidekiq
  copy_file 'config/sidekiq.yml'
  gsub_file('config/sidekiq.yml', /%app_name%/, application_name)
end

sidekiq
