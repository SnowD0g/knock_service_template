require "fileutils"
require "shellwords"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_5?
  Gem::Requirement.new(">= 5.2.0", "< 6.0.0.beta1").satisfied_by? rails_version
end

def rails_6?
  Gem::Requirement.new(">= 6.0.0.beta1", "< 7").satisfied_by? rails_version
end

def add_gems
  gem 'pg', '>= 0.18', '< 2.0'
  gem 'redis', '~> 4.0', '>= 4.0.1'
  gem 'jbuilder', '~> 2.5'
  gem 'jbuilder_cache_multi'
  gem 'rb-readline'
  gem 'faraday', '~> 0.15.4'
  gem 'rack-cors'
  gem 'dotenv-rails'
  gem 'kaminari'
  gem 'jbuilder_pagination', require: 'jbuilder/pagination'
  gem 'knock'
  gem_group :development do
    gem 'listen', '>= 3.0.5', '< 3.2'
    gem 'spring'
    gem 'spring-watcher-listen', '~> 2.0.0'
    gem 'capistrano', '3.10.2'
    gem 'capistrano-rvm'
    gem 'capistrano-ssh-doctor'
    gem 'capistrano-rails'
    gem 'capistrano-passenger'
  end
end

def set_application_name
  # Add Application Name to Config
  if rails_5?
    environment "config.application_name = Rails.application.class.parent_name"
  else
    environment "config.application_name = Rails.application.class.module_parent_name"
  end

  # Announce the user where he can change the application name in the future.
  puts "You can change application name inside: ./config/application.rb"
end

def add_autoload_paths
  application "config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]"
  application "config.autoload_paths += Dir[Rails.root.join('app', 'controllers', '{**/}')]"
end

def enable_pg_uuid_extension
  generate "migration enable_pgcrypto_extension"
  file_name = Dir.entries("db/migrate").select{ |file| file.include?('enable_pgcrypto_extension')}.first
  insert_into_file 'db/migrate/file_name', "enable_extension 'pgcrypto'", after: "def change"
  application 'config.generators { |generator| generator.orm :active_record, primary_key_type: :uuid }'
end

def enable_redis_caching
  environment 'config.action_controller.perform_caching = true', env: 'development'
  environment 'config.cache_store = :redis_cache_store', env: 'development'
end

def add_knock
  # Initialize
  generate "knock:install"
  gsub_file('config/initializers/knock.rb'), 
    '# config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }',
    'config.token_secret_signature_key = -> { Rails.application.credentials.jwt_secret }'
    
  # User Model
  generate "migration User email password_digest type"
  copy_file 'app/models/users/user.rb'

 
  # Api Base Controller
  copy 'app/controllers/concerns/permission.rb'
  copy_file 'api/v1/base_controller.rb'

  # Knock Controller
  copy_file 'api/v1/user_token_controller.rb'
end

def stop_spring
  run "spring stop"
end

# Main setup
add_template_repository_to_source_path
add_gems
add_autoload_paths

after_bundle do
  set_application_name
  stop_spring
  
  enable_pg_uuid_extension
  enable_redis_caching

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"

  # Commit everything to git
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
