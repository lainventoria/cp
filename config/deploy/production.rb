set :deploy_user, 'gestion'
set :deploy_to, "/home/#{fetch(:deploy_user)}/deploy/#{fetch(:application)}"

server 'sion.duvium.com', port: 22070, user: fetch(:deploy_user), roles: %w{app web db}
