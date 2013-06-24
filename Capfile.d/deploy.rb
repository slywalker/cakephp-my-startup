set :application, "set your application name here"
set :repository,  "set your repository location here"
set :branch, "master"
set :scm, :git

# Roles & servers
role :app, "your app-server here"
set :user, 'ubuntu'

# Deploy settings
set :deploy_to, "/home/ubuntu/#{application}"
set :deploy_via, :checkout
set :copy_cache, true
set :copy_exclude, [".git/*", ".gitignore"]

# Options
set :use_sudo, false
set :keep_releases, 5

after "deploy:setup", "cakephp:setup"
after "deploy:setup", "composer:setup"
after "deploy:setup", "nginx:setup"

after "deploy", "composer:install"
after "deploy", "cakephp:restart"

namespace :composer do
  desc "Install composer and composer install"
  task :setup, :roles => :app do
    run "cd #{shared_path} && curl -s https://getcomposer.org/installer | php"
  end

  task :install, :roles => :app do
    run "cd #{current_release} && php #{shared_path}/composer.phar install"
  end
end

namespace :cakephp do
  desc "Blow up all the cache files CakePHP uses, ensuring a clean restart."
  task :setup, :roles => :app do
    # Create TMP folders
    run "mkdir -p #{shared_path}/tmp/sessions"
    run "mkdir -p #{shared_path}/tmp/logs"
    run "mkdir -p #{shared_path}/tmp/tests"
    run "mkdir -p #{shared_path}/tmp/cache/models"
    run "mkdir -p #{shared_path}/tmp/cache/persistent"
    run "mkdir -p #{shared_path}/tmp/cache/views"
    run "chmod -R 777 #{shared_path}/tmp"

    # Create WEBROOT folders
    run "mkdir -p #{shared_path}/webroot/files"
    run "chmod -R 777 #{shared_path}/webroot/files"
  end

  task :restart, :roles => :app do
    # Link uploaded files.
    run "rm -rf #{current_release}/webroot/files"
    run "ln -s #{shared_path}/webroot/files #{current_release}/webroot/files"

    # Link tmp
    run "rm -rf #{current_release}/tmp"
    run "ln -s #{shared_path}/tmp #{current_release}/tmp"

    # Remove absolutely everything from TMP
    run "find #{shared_path}/tmp -type f ! -name empty | #{sudo} xargs --no-run-if-empty rm"
    run "#{sudo} /etc/init.d/php5-fpm restart"
  end
end

namespace :nginx do
  desc "Config file upload"
  task :setup, :roles => :app do
    run "#{sudo} mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.$(date +%Y%m%d_%H%M%S)"
    put IO.read('Capfile.d/files/default'), "#{deploy_to}/default.tmp", :mode => 0644
    run "#{sudo} mv #{deploy_to}/default.tmp /etc/nginx/sites-available/default"
  end

  desc "Nginx restart"
  task :restart, :roles => :app do
    run "#{sudo} /etc/init.d/nginx restart"
  end
end