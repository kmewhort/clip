# pull code from github repo
set :application, "clip"
set :repository,  "git@github.com:kmewhort/clip.git"
set :branch, "master"
set :scm, "git"
set :ssh_options, { :forward_agent => true }

# single-server deployment at clipol.org
role :web, "clipol.org"
role :app, "clipol.org"
role :db,  "clipol.org"
default_run_options[:pty] = true
set :user, "kent"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/clipol"

# keep the licence review_pending files shared between deployments
set :shared_children, %w{public/system log tmp/pids public/review_pending}

# merge any new data files from the repository into the shared system directory
before "deploy:finalize_update", "deploy:merge_system_directory"
namespace :deploy do
  task :merge_system_directory do
    run "rsync -pr #{release_path}/public/system/licences #{shared_path}/system/licences"
  end
end


# cleanup each deploy
after "deploy:restart", "deploy:cleanup"

# restart Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end