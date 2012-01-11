# RVM bootstrap
$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.2'
set :rvm_type, :user

set :application, "mangatha"
set :repository,  "git://git01.thoughtworks.com/mangatha/mangatha.git"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :user, 'mankatha'
set :deploy_to, '/home/mankatha/mangatha'
set :use_sudo, false
set :bundle_cmd, '~/.rvm/bin/rvm exec bundle'
set :shared_path, '/home/mankatha/mangatha/shared'
set :bundle_gemfile, "Gemfile"
set :budnle_dir, File.join(fetch(:shared_path), 'bundle')
set :bundle_flags,    "--deployment --quiet"
set :bundle_without,  [:development, :test]

role :web,'10.10.5.34'    # Your HTTP server, Apache/etc
role :app, '10.10.5.34'   # This may be the same as your `Web` server

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do 
    run "cd #{current_path}; rm -rf #{current_path}/tmp/pids; rm -rf #{current_path}/log; bin/passenger start -euat -d "
  end
  task :stop do
    run "cd #{current_path}; bin/passenger stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    #run "touch #{current_path}/tmp/restart.txt"
    run "cd #{current_path}; rm -rf #{current_path}/tmp/pids; rm -rf #{current_path}/log; bin/passenger start -euat -d "
  end

  task :remove do
    run "cd #{current_path}; bin/passenger stop"
  end
end

namespace :bundler do
  desc "Symlink bundled gems on each release"
  task :symlink_bundled_gems, :roles => :app do
    run "mkdir -p #{shared_path}/bundled_gems"
    run "ln -nfs #{shared_path}/bundled_gems #{release_path}/vendor/bundle"
  end

  desc "Install for production"
  task :install, :roles => :app do
    run "cd #{release_path} && bundle install --binstubs"
  end

end

before 'deploy:symlink', 'deploy:remove'
after 'deploy:update_code', 'bundler:symlink_bundled_gems'
after 'deploy:update_code', 'bundler:install'
