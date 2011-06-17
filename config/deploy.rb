set :application, "hoptopus"
set :repository,  "git@github.com:bradhe/hoptopus.git"

set :scm, :git

role :web, "ec2.hoptopus.com"
role :app, "ec2.hoptopus.com"
role :db,  "ec2.hoptopus.com"

set :deploy_to, '/www/hoptopus'

set :use_sudo, false
#set :user, 'deploy'
#set :password, '!!abc123'
set :application, "hoptopus.com"
set :domain, "ec2-50-19-13-135.compute-1.amazonaws.com"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :bootstrap_deploy_user do
    system "ssh -i #{aws_private_key_path} ubuntu@#{domain} \"sudo groupadd admin\""
    system "ssh -i #{aws_private_key_path} ubuntu@#{domain} \"sudo useradd -d /home/#{user} -s /bin/bash -m #{user}\""
    system "ssh -i #{aws_private_key_path} ubuntu@#{domain} \"echo #{user}:#{password} | chpasswd\""
    system "ssh -i #{aws_private_key_path} ubuntu@#{domain} \"sudo usermod -a -G admin deploy\""
    system "ssh -i #{aws_private_key_path} ubuntu@#{domain} \"sudo mkdir /home/#{user}/.ssh\""
    system "ssh -i #{aws_private_key_path} ubuntu@#{domain} \"sudo chown -R #{user}:#{user} /home/#{user}/.ssh\""
    system "scp -i #{aws_private_key_path} config/deploy_sudoers ubuntu@#{domain}:/etc/sudoers"
  end
end
