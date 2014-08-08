lock '3.2.1'

set :application, 'cp'
set :repo_url, 'git@github.com:lainventoria/cp.git'

# Defaults de capistrano que usamos
# set :branch, :master
# set :scm, :git
# set :format, :pretty
# set :log_level, :debug
# set :pty, false
# set :keep_releases, 5

set :rbenv_ruby, '2.0.0-p353'

set :linked_files, %w{config/database.yml config/secrets.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: '/opt/ruby/bin:$PATH' }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Para reiniciar passenger
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart
end
