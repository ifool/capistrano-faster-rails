# Welcome to use `capistrano-faster-rails`!

## What does this gem do?

1. Execute copy `linked_files` and `linked_dirs` with one command on deployed servers.

Capistrano runs each command separately on their own SSH session and it takes too long to deploy an application, copy `linked_files` and `linked_dirs` on deployed servers with one command will speedup deploying process.

2. Skip `bundle install` if Gemfile isn't changed.

`bundle install` takes few or dozens of seconds, most of the time your project's Gemfile will not be changed, and you don't have to execute `bundle install` if your Gemfile isn't changed.

3. Skip `rake assets:precompile` if asset files not chagned.

`rake assets:precompile` is really slow if your Rails project has plenty of assets to precompile, even if they are not changed. You don't have to execute `rake assets:precompile` if your asset files not chagned.


## Installation

Add this line to your Rails application's Gemfile and below to `gem 'capistrano-rails'`:

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

Causion:

`asset_files` and `bundle_files` are both space separated string, not array!

this gem only works with `git` scm!



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ifool/capistrano-faster-rails.
