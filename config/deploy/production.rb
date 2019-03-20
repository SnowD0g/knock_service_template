server 'ns3051471.ovh.net', user: 'root', roles: %w{app db web}
set :stage, :production
set :branch, :master
set :deploy_to, "/home/web/www/#{fetch(:application)}"

set :ssh_options, {
    keys: %w(/home/.ssh/id_rsa),
    forward_agent: false,
    auth_methods: %w(password)
}
