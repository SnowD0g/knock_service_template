server 'ns3051471.ovh.net', user: 'web', roles: %w{app db web}
set :stage, :staging
set :branch, :staging
set :deploy_to, "/home/web/www/#{fetch(:application)}_staging"

set :ssh_options, {
    keys: %w(/home/.ssh/id_rsa),
    forward_agent: false,
    auth_methods: %w(password)
}
