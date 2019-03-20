set :application, "%application_name%"
set :repo_url, "%remote_repo%"

set :rvm_ruby_version, "%ruby_version%@%application_name%"

set :passenger_rvm_ruby_version, fetch(:rvm_ruby_version)
set :passenger_restart_command, 'touch tmp/restart.txt'
set :passenger_restart_options, ''

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
#append :linked_files, 'config/master.key'
#append :linked_files, 'config/.env'

before 'deploy', 'rvm:create_gemset'

set :keep_releases, 3
