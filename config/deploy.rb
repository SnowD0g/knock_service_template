require "rvm/capistrano"

set :application, "%application_name%"
set :repo_url, "%repo_path%"

set :rvm_ruby_version, "%ruby_version%@%application_name%"

set :passenger_rvm_ruby_version, fetch(:rvm_ruby_version)
set :passenger_restart_command, 'touch tmp/restart.txt'
set :passenger_restart_options, ''

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
#append :linked_files, 'config/master.key'
#append :linked_files, 'config/.env'

set :keep_releases, 3

task :create_gemset do
  on roles(:app) do
    execute :sudo, :rvm, "use #{fetch(:rvm_ruby_version)} --create"
  end
end
