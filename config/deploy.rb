set :rvm_type, :system

set :application, "cineprovision"
set :repository,  "git@github.com:KevinTriplett/cineprovision.git"
set :user, "webadmin"
# can't use fast_remote_cache till SSH keys are set up
# set :deploy_via, :fast_remote_cache
set :deploy_via, :copy
set :copy_exclude, %w(.git doc test)
set :scm, :git

# Customize the deployment
set :tag_on_deploy, false # turn off deployment tagging, we have our own tagging strategy

set :keep_releases, 6
before "deploy", "deploy:check_revision"
after "deploy:update", "deploy:cleanup"

# directories to preserve between deployments
# set :asset_directories, ['public/system/logos', 'public/system/uploads']

# re-linking for config files on public repos
# namespace :deploy do
#   desc "Re-link config files"
#   task :link_config, :roles => :app do
#     link "#{current_path}/config/database.yml" => "#{shared_path}/config/database.yml"
#   end
# end
#
# def link(link)
#   source, target = link.keys.first, link.values.first
#   run "ln -nfs #{target} #{source}"
# end

namespace :deploy do
  desc "Make sure there is something to deploy"
  task :check_revision, :roles => [:web] do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts ""
      puts "  \033[1;33m**************************************************\033[0m"
      puts "  \033[1;33m* WARNING: HEAD is not the same as origin/#{branch} *\033[0m"
      puts "  \033[1;33m**************************************************\033[0m"
      puts ""

      exit
    end
  end
end
