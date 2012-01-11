set :application, "mangatha"
set :repository,  "git://git01.thoughtworks.com/mangatha/mangatha.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, 'mankatha'
set :deploy_to, '/home/mankatha/mangatha'
set :use_sudo, false

role :web,'10.10.5.34'    # Your HTTP server, Apache/etc
role :app, '10.10.5.34'   # This may be the same as your `Web` server

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do 
    run "rvm 1.9.2 do ruby #{current_path}/script/rails s -d -e uat"
  end
  task :stop do 
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
  #  run "cd #{current_path}; rvmsudo script/rails server stop"
    run " touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
