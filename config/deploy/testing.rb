lock "3.9.1"
set :application, "sparc-fulfillment"
#set :rvm_ruby_version, "ruby-2.4.2@sparc-request"
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.5'
set :repo_url, 'git@github.com:BI-CTSICN/sparc-fulfillment.git'
set :deploy_to, "/opt/SPARC_DEVELOPMENT/sparc-request-release-2.0.5/sparc-fulfillment-capistrano"
set :rails_env, "testing"
server '10.54.13.48', user: 'capistrano', roles: %w{app db web}
set :branch, "cnmc-v2.6.0"
set :passenger_restart_with_touch, true

