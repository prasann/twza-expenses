set :application, "mangatha"
set :repository,  "git://github.com:prasann/twza-expenses.git"
set :scm, :git
set :deploy_to, '/home/mankatha/mangatha'
set :log_level, :info
set :use_sudo, false
set :bundle_cmd, '~/.rvm/bin/rvm exec bundle'
set :user, "mankatha"

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
role :app, "server_ip"
role :web, "server_ip"

namespace :deploy do
  task :before_deploy do
  	on roles(:web) do
		abort "ERROR: No stage specified. Please specify one of: uat, production (e.g. `cap uat deploy')" if stage.nil?
    end
  end
  task :start do
  	on roles(:web) do
    	run "sudo /sbin/service nginx start"
    end
  end
  task :stop do
  	on roles(:web) do
    	run "sudo /sbin/service nginx stop"
    end
  end
  task :restart do
  	on roles(:app) do
    	run "sudo /sbin/service nginx restart"
  	end
  end
end

namespace :bundler do
  desc "Install for production"
  task :install do 
  	on roles(:app) do
    	run "cd #{release_path} && bundle install --binstubs --without=development test"
    end
  end
end

namespace :git do
  task :create_revision_page do
    run "cd #{release_path} && git log -n 1 > public/revision.txt"
  end
end

namespace :mailman do
  task :start do
  	on roles(:app) do
    	run "cd #{release_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon start"
    end
  end
  
  task :stop do
  	on roles(:app) do
    	run "cd #{release_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon stop"
    end
  end
 
  task :restart do
  	on roles(:app) do
    	mailman.stop
    	mailman.start
    end
  end
end	