set :application, 'name'
set :repo_url, 'git_repo'

set :branch, 'master'
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, 'deploy_path'
set :scm, :git

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
#set :linked_dirs, %w{php/data}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
 set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :gitpush do
   on roles(:all), in: :groups, limit: 3, wait: 5 do
      puts "\n=== git push task ===\n"
      if test("ls #{deploy_to}")
        info "deploy_to ok"
      else
        error "error on deploy_to"
      end

      if test "[ -d #{deploy_to}git ]"
         within "#{deploy_to}git" do
           execute :git, :pull, "origin master"
         end
      else
         execute :git, :clone, "#{repo_url}", "#{deploy_to}git"
      end

      within "#{deploy_to}git" do
        if test "cd #{deploy_to}git && git remote show prod"
           info "remote ok"

        else
          info  "add remote"
          execute :git, :remote, "add prod -f #{fetch(:gitpush_url)}"
        end
       execute :git, :merge, "prod/master -s recursive -X ours"
       execute :git, :push, "prod HEAD"
       end
     end
   end


end
