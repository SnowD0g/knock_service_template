require "fileutils"
require "shellwords"

DEFAULTS = %w(my_app ruby-2.5.1 web@ns3051471.ovh.net /var/git/)

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
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def init_application
  apply('democom_application.rb')

  puts 'Inizializzo Applicazione'
  default_app_name, default_ruby_version, default_server_url, repo_path = DEFAULTS

  app_name = ask_with_default("Nome Applicazione)", default_app_name)
  ruby_version = ask_with_default("Versione Ruby)", default_ruby_version)
  server_url = ask_with_default("Url server remoto)", default_server_url)
  repo_path = ask_with_default("Path del repository remoto)", repo_path)

  @democom_application ||= DemocomApplication.new(app_name, ruby_version, server_url, repo_path)
end

def application_name
  @democom_application.application_name
end

def repo_name
  @democom_application.repo_name
end

def remote_repo
  @democom_application.remote_repo
end

def ruby_version
  @democom_application.ruby_version
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
  gem 'foreman'
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
  gem 'sidekiq'
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
  application "config.autoload_paths += Dir[Rails.root.join('app', '{**/}')]"
end

def enable_redis_caching
  rails_command "db:create"
  environment 'config.cache_store = :redis_cache_store', env: 'development'
end

def add_knock
  # Initialize
  generate "knock:install"
  gsub_file('config/initializers/knock.rb', /# config.token_secret_signature_key = -> { Rails.application.secrets.secret_key_base }/,'config.token_secret_signature_key = -> { Rails.application.credentials.jwt_secret }')
    
  # User Model
  generate "migration create_user email password_digest type"
  copy_file 'app/models/users/user.rb'
  # Api Base Controller
  copy_file 'app/controllers/concerns/permission.rb'
  copy_file 'app/controllers/api/v1/base_controller.rb'

  # Knock Controller
  copy_file 'app/controllers/api/v1/user_token_controller.rb'
  
  # aggiungere routes
  content = <<-RUBY
    namespace :api do
      namespace :v1, defaults: { :format => :json } do
        post 'user_token' => 'user_token#create'
      end
    end
  RUBY
  
  insert_into_file "config/routes.rb", "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def stop_spring
  run "spring stop"
end

def configure_db
  apply('shared/database.rb')
end

def init_git
  apply('shared/git.rb')
end

def init_sidekiq
  apply('shared/sidekiq.rb')
end

def init_capistrano
  apply('shared/capistrano.rb')
end

def init_foreman
  copy_file('Procfile')
  run "foreman start"
end

def ask_with_default(question, default, color = :blue)
  return default unless $stdin.tty?
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

# Main setup
add_template_repository_to_source_path
init_application
add_gems
add_autoload_paths

after_bundle do
  stop_spring
  configure_db
  add_knock
  enable_redis_caching

  # Migrate
  rails_command "db:create"
  rails_command "db:migrate"
  remove_file 'db/seeds.rb' 
  copy_file 'db/seeds.rb'
  rails_command "db:seed"

  # Service
  init_sidekiq

  # Commit everything to git
  init_git
  
  # Capistrano
  init_capistrano

  # Foreman
  init_foreman
end
