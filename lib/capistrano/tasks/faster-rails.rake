set :conditionally_migrate, true

namespace :deploy do
  namespace :symlink do
    Rake::Task["deploy:symlink:linked_files"].clear_actions
    task :linked_files do
      next unless any? :linked_files
      on release_roles :all do
        link_cmd = "mkdir -p #{linked_file_dirs(release_path).join(' ')}\n"
        link_cmd << fetch(:linked_files).map { |file|
          source_file = shared_path.join(file).to_s.ljust(40, ' ')
          "ln -sf #{source_file} #{release_path.join(file)}"
        }.join("\n")
        execute(link_cmd.tap { |s| puts s })
      end
    end

    Rake::Task["deploy:symlink:linked_dirs"].clear_actions
    task :linked_dirs do
      next unless any? :linked_dirs
      on release_roles :all do
        link_cmd = "mkdir -p #{linked_dir_parents(release_path).join(' ')}\n"
        link_cmd << "cd #{release_path} && rm -rf #{fetch(:linked_dirs).join(' ')}\n"
        link_cmd << fetch(:linked_dirs).map { |dir_name|
          source_dir = shared_path.join(dir_name).to_s.ljust(40, ' ')
          "ln -sf #{source_dir} #{release_path.join(dir_name)}"
        }.join("\n")
        execute(link_cmd.tap { |s| puts s })
      end
    end
  end

  namespace :assets do
    Rake::Task["deploy:assets:precompile"].clear_actions
    task :precompile do
      on(release_roles(fetch(:assets_roles))) {
        log "[deploy:assets:precompile] Checking assets changes"
        asset_files = fetch(:asset_files, "vendor/assets app/assets config/initializers/assets.rb")
        asset_changed = within(repo_path) {
          previous_revision = fetch(:previous_revision) rescue ''
          current_revision  = fetch(:current_revision)
          previous_revision.to_s.empty? ||
            !capture("cd #{repo_path} && git diff --name-only #{previous_revision} #{current_revision} -- #{asset_files} | head -n 3").empty?
        }
        if asset_changed
          within(release_path) do
            with rails_env: fetch(:rails_env), rails_groups: fetch(:rails_assets_groups) do
              execute :rake, "assets:precompile"
            end
          end
        else
          log "[deploy:assets:precompile] Skip `deploy:assets:precompile` (assets not changed)"
        end
      }
    end
  end
end

namespace :bundler do
  desc 'Install the current Bundler environment.'
  Rake::Task["bundler:install"].clear_actions
  task :install do
    on fetch(:bundle_servers) do
      log "[bundler:install] Checking Gemfile and Gemfile.lock changes"
      bundle_files = fetch(:bundle_files, "Gemfile Gemfile.lock .ruby-version")
      gemfile_changed = within(repo_path) {
        previous_revision = fetch(:previous_revision) rescue ''
        current_revision  = fetch(:current_revision)
        previous_revision.to_s.empty? ||
          !capture("cd #{repo_path} && git diff --name-only #{previous_revision} #{current_revision} -- #{bundle_files}").empty?
      }

      within(release_path) {
        with(fetch(:bundle_env_variables) || {}) do
          options = []
          options << "--gemfile #{fetch(:bundle_gemfile)}" if fetch(:bundle_gemfile)
          options << "--path #{fetch(:bundle_path)}" if fetch(:bundle_path)
          unless test(:bundle, :check, *options)
            options << "--binstubs #{fetch(:bundle_binstubs)}" if fetch(:bundle_binstubs)
            options << "--jobs #{fetch(:bundle_jobs)}" if fetch(:bundle_jobs)
            options << "--without #{fetch(:bundle_without)}" if fetch(:bundle_without)
            options << "#{fetch(:bundle_flags)}" if fetch(:bundle_flags)
            if gemfile_changed
              execute :bundle, :install, *options
            else
              log "[bundler:install] Skip `bundle install` (Gemfile and Gemfile.lock not changed)"
              execute :mkdir, "-p", ".bundle"
              execute :echo, %Q['BUNDLE_FROZEN: "true"\nBUNDLE_WITHOUT: "development:test"'], '>>', '.bundle/config'
            end
          end
        end
      }
    end
  end
end

yarn_install_task = Rake::Task["yarn:install"] rescue nil
if yarn_install_task
  yarn_install_task.clear_actions

  namespace :yarn do
    Rake::Task["yarn:install"]
    task :install do
      on roles fetch(:yarn_roles) do
        log "[yarn:install] Checking package.json and yarn.lock changes"
        asset_files = fetch(:asset_files, "package.json yarn.lock")
        asset_changed = within(repo_path) {
          previous_revision = fetch(:previous_revision) rescue ''
          current_revision  = fetch(:current_revision)
          previous_revision.to_s.empty? ||
            !capture("cd #{repo_path} && git diff --name-only #{previous_revision} #{current_revision} -- #{asset_files}").empty?
        }
        if asset_changed
          within fetch(:yarn_target_path, release_path) do
            with fetch(:yarn_env_variables, {}) do
              execute fetch(:yarn_bin), 'install', fetch(:yarn_flags)
            end
          end
        else
          log "[yarn:install] Skip `yarn:install` (package.json and yarn.lock not changed)"
        end
      end
    end
  end
end
