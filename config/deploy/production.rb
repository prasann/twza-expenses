set :application, "mangatha"
set :repository,  "git://github.com:prasann/twza-expenses.git"
set :scm, :git
set :deploy_to, '/home/mankatha/mangatha'
set :log_level, :info
set :use_sudo, false
set :bundle_cmd, '~/.rvm/bin/rvm exec bundle'
set :user, "mankatha"

role :app, "server_ip"
role :web, "server_ip"

server 'server_ip', user: 'user_name', password: 'password'

namespace :deploy do
  task :before_deploy do
  	on roles(:web) do
		abort "ERROR: No stage specified. Please specify one of: uat, production (e.g. `cap uat deploy')" if stage.nil?
    end
  end
  task :start do
  	on roles(:web) do
    	execute "sudo /sbin/service nginx start"
    end
  end
  task :stop do
  	on roles(:web) do
    	execute "sudo /sbin/service nginx stop"
    end
  end
  task :restart do
  	on roles(:app) do
    	execute "sudo /sbin/service nginx restart"
  	end
  end
end

namespace :bundler do
  desc "Install for production"
  task :install do 
  	on roles(:app) do
    	execute "cd #{release_path} && bundle install --binstubs --without=development test"
    end
  end
end

namespace :git do
  task :create_revision_page do
    execute "cd #{release_path} && git log -n 1 > public/revision.txt"
  end
end

namespace :mailman do
  task :start do
  	on roles(:app) do
    	execute "cd #{release_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon start"
    end
  end
  
  task :stop do
  	on roles(:app) do
    	execute "cd #{release_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon stop"
    end
  end
 
  task :restart do
  	on roles(:app) do
    	mailman.stop
    	mailman.start
    end
  end
end	