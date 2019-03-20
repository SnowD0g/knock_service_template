# Load DSL and set up stages
require 'capistrano/setup'
require 'capistrano/ssh_doctor'
require 'capistrano/deploy'
require "rvm/capistrano"
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/passenger'
require 'capistrano/scm/git'

install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
