set :rails_env, 'staging' # production or staging
set :branch, 'master'
set :deploy_to, "/mnt/web2/#{application}/#{rails_env}"
set :keep_release, 1 # 1 is good for staging, 2 or more is better for production
