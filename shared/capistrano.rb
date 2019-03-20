def set_environments
  copy_file 'config/deploy/production.rb'
  copy_file 'config/deploy/staging.rb'
end

def capfile
  copy_file 'Capfile'
end

def deploy
  copy_file 'config/deploy.rb'
  gsub_file('config/deploy.rb', /%application_name%/, application_name)
  gsub_file('config/deploy.rb', /%remote_repo%/, remote_repo)
  gsub_file('config/deploy.rb', /%ruby_version%/, ruby_version)
end

def check_deploy
  run 'cap production rvm:create_gemset'
  run 'cap production deploy:check'
  run 'cap staging deploy:check'
end

def init_capistrano
  capfile
  deploy
  set_environments
  check_deploy
end

init_capistrano
