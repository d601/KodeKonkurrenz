set :application, 'KodeKonkurrenz'
set :repo_url, 'git@github.com/d601/KodeKonkurrenz.git'
set :branch, 'test'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# might need to delete this crap - i added it based on stuff other people wrote
set :deploy_to, '/home/web/deployment/test/'
set :use_sudo, false
set :deploy_via, :copy
set :scm, :git
# end delete crap

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'
end
