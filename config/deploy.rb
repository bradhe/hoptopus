set :application, "hoptopus"
set :repository,  "git@github.com:bradhe/hoptopus.git"

set :scm, :git

role :web, "ec2-50-19-13-135.compute-1.amazonaws.com"
role :app, "ec2-50-19-13-135.compute-1.amazonaws.com"
role :db,  "ec2-50-19-13-135.compute-1.amazonaws.com"

set :deploy_to, '/www/hoptopus'

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
