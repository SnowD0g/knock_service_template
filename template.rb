require "fileutils"
require "shellwords"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("service-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/SnowD0g/knock_service_template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{jumpstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

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

def add_autoload_paths
  application "config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]"
  application "config.autoload_paths += Dir[Rails.root.join('app', 'controllers', '{**/}')]"
end

def enable_pg_uuid_extension
  generate "migration enable_pgcrypto_extension"
  file_name = Dir.entries("db/migrate").select{ |file| file.include?('enable_pgcrypto_extension')}.first
  insert_into_file "db/migrate/#{file_name}", "enable_extension 'pgcrypto'", after: "def change"
  application 'config.generators { |generator| generator.orm :active_record, primary_key_type: :uuid }'
end

def enable_redis_caching
  environment 'config.action_controller.perform_caching = true', env: 'development'
  environment 'config.cache_store = :redis_cache_store', env: 'development'
end

def add_knock
  # Initialize
  generate "knock:install"
  gsub_file('config/initializers/knock.rb', /# config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }/,'config.token_secret_signature_key = -> { Rails.application.credentials.jwt_secret }')
    
  # User Model
  rails_command "g migration create_user email password_digest type"
  copy_file 'app/models/users/user.rb'

 
  # Api Base Controller
  copy_file 'app/controllers/concerns/permission.rb'
  copy_file 'app/controllers/api/v1/base_controller.rb'

  # Knock Controller
  copy_file 'app/controllers/api/v1/user_token_controller.rb'
end

def stop_spring
  run "spring stop"
end

def configure_db
  remove_file 'config/database.yml'
  copy_file 'config/database.yml'
  puts("\n[Database Config][username][1/3]")
  db_username =  ask("Nome Utente ? (postgres)")
  db_username = 'postgres' unless db_username.present?
  puts("\n[Database Config][database][2/3]")
  db_name = ask("Nome database ? (rails_app)")
  db_name = 'rails_app' unless db_name.present?
  puts("\n[Database Config][port][3/3]")
  db_port = ask("Porta del servizio ? (32770)")
  db_port = '32770' unless db_port.present?
  
  gsub_file('config/database.yml', /%username%/, db_username)
  gsub_file('config/database.yml', /%port%/, db_port)
  gsub_file('config/database.yml', /%application_name%/, db_name)
end

# Main setup
add_template_repository_to_source_path
add_gems
add_autoload_paths

after_bundle do
  stop_spring
  add_knock
  configure_db
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
