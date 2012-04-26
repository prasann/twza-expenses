# RVM bootstrap
$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3'
set :rvm_type, :user

set :application, "mangatha"
set :repository,  "git://git01.thoughtworks.com/mangatha/mangatha.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "mankatha"
set :password, "!abcd1234"
set :deploy_to, '/home/mankatha/mangatha'
set :use_sudo, false
default_run_options[:pty] = true
set :bundle_cmd, '~/.rvm/bin/rvm exec bundle'
set :stage, nil

task :uat do
  set :stage, "uat"
  role :web, "10.10.5.34"                          # Your HTTP server, Apache/etc
  role :app, "10.10.5.34"                          # This may be the same as your `Web` server
end

task :production do
  set :stage, "production"
  role :web, "10.10.5.54"                          # Your HTTP server, Apache/etc
  role :app, "10.10.5.54"                          # This may be the same as your `Web` server
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:

namespace :deploy do
  task :before_deploy do
    abort "ERROR: No stage specified. Please specify one of: uat, production (e.g. `cap uat deploy')" if stage.nil?
  end
 task :start do
    run "sudo /sbin/service nginx start"
  end
  task :stop do
    run "sudo /sbin/service nginx stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo /sbin/service nginx restart"
  end
end

namespace :bundler do
  desc "Install for production"
  task :install, :roles => :app do
    run "cd #{release_path} && bundle install --binstubs --without=development test"
  end
end

namespace :git do
  task :create_revision_page do
    run "cd #{release_path} && git log -n 1 > public/revision.txt"
  end
end

before 'deploy:update_code', 'deploy:before_deploy'
after 'deploy:update_code', 'bundler:install'
