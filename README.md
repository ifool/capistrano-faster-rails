# Welcome to use `capistrano-faster-rails`!

## What does this gem do?

1. Set `conditionally_migrate` to true to skip `rails db:migrate` if migration files not changed.

2. Execute copy `linked_files` and `linked_dirs` with one command on deployed servers.

Capistrano runs each command separately on their own SSH session and it takes too long to deploy an application, copy `linked_files` and `linked_dirs` on deployed servers with one command will speedup deploying process.

3. Skip `bundle install` if Gemfile isn't changed.

`bundle install` takes a few seconds even if Gemfile isn't changed, there is no need to execute `bundle install` if it isn't changed.

4. Skip `rake assets:precompile` and `yarn:install` if asset files aren't chagned.

`rake assets:precompile` and `yarn:install` is really slow if your Rails project has plenty of assets to precompile, even if they are not changed. There is no need to execute these commands if asset files not chagned.


## Installation

Add this line to your Rails application's Gemfile and below to `gem 'capistrano-rails'`. if your project have `capistrano-yarn` installed, please add this line below to `gem 'capistrano-yarn'` too.

```ruby
# Gemfile
gem 'capistrano-faster-rails'
```

And then execute:

    $ bundle

## Usage

Add this line to your Rails application's Capfile and below to `require 'capistrano/rails'`:

```ruby
# Capfile
require 'capistrano/faster-rails'
```

use `set :asset_files` in config/deploy.rb to set your project assets files, `asset_files` default to `"vendor/assets app/assets config/initializers/assets.rb"`

use `set :bundle_files` in config/deploy.rb to set your project ruby Gemfile files, `bundle_files` default to `"Gemfile Gemfile.lock .ruby-version"`

## Note

`asset_files` and `bundle_files` are both space separated string, not array!

this gem only works with `git` scm!



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ifool/capistrano-faster-rails.
