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
set :bundle_cmd, '~/.rvm/bin/rvm exec bundle'

role :web, "10.10.5.34"                          # Your HTTP server, Apache/etc
role :app, "10.10.5.34"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:

 namespace :deploy do
   task :start do
     environment = ENV['env'] || 'uat'
     run "cd #{current_path}; bin/passenger start -d -e#{environment}"
   end
   task :stop do
     run "cd #{current_path}; bin/passenger stop"
   end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run " touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end

namespace :bundler do
  desc "Install for production"
  task :install, :roles => :app do
    run "cd #{release_path} && bundle install --binstubs"
  end
end

namespace :git do
  task :create_revision_page do
    run "cd #{release_path} && git log -n 1 > public/revision.txt"
  end
end     

after 'deploy:update_code', 'bundler:install'

