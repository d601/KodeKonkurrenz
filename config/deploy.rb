set :application, 'KodeKonkurrenz'
set :repo_url, 'https://github.com/d601/KodeKonkurrenz.git'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# might need to delete this crap - i added it based on stuff other people wrote
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
      execute :mkdir, release_path.join('tmp')
      execute :touch, release_path.join('tmp/restart.txt')
      # Apache's user is www-data. Obviously it needs to be able to read the files it is serving.
      execute :chown, "-R", ":www-data", "#{deploy_to}"
      # This fixes permissions according to
      # 4.2. Deploying to a virtual host’s root
      # of the Passenger manual. I have not actually determined if this helps. -js
      execute :chmod, "-R", "g+rx", release_path.join('public')
      execute :chmod, "g+rx", release_path
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
    on roles(:web) do
      execute :rm, "-f", "/tmp/git-ssh.sh"
    end
  end

end
