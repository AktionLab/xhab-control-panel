require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'
require './config/boot'

set :stages, %w(production staging)

ssh_options[:username] = 'deployer'
ssh_options[:forward_agent] = true

set :application, "xhab-control-panel"
set :repository, "git@github.com:AktionLab/#{application}" # assuming the repo name is the same as the application, as it should be
set :scm, :git
set :rvm_type, :user
set :rvm_ruby_string, "1.9.3-p327@#{application}"
set :use_sudo, false
set :server_hostname, "50.19.209.101"
set :port, 2222

# include any files that need to be symlinked into the new release, usually configuration files are loaded this way.
set :symlinks, %w(config/database.yml config/unicorn.rb)

role :web, server_hostname
role :app, server_hostname
role :db,  server_hostname, :primary => true

before 'deploy:assets:precompile', 'deploy:symlink_shared'
after  'deploy:assets:precompile', 'deploy:rake_tasks'
after  'deploy:rake_tasks',        'nginx:config'
after  'nginx:config',             'nginx:reload'
after  'deploy',                   'deploy:cleanup'

namespace :deploy do
  %w(start stop restart).each do |action|
    task(action) { run "cd #{current_path} && RAILS_ENV=#{rails_env} script/unicorn #{action}" }
  end

  task :symlink_shared, :except => {:no_release => true} do
    run(symlinks.map {|link| "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"}.join(' && '))
  end

  task :rake_tasks, :except => {:no_release => true} do
    run "cd #{release_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
  end
end

namespace :nginx do
  task :config do
    run "sudo rm -f /etc/nginx/sites-enabled/#{application}_#{rails_env} && sudo ln -nfs #{release_path}/config/nginx_#{rails_env}.conf /etc/nginx/sites-enabled/#{application}_#{rails_env}"
  end

  task :reload do
    run "sudo /etc/init.d/nginx reload"
  end
end
