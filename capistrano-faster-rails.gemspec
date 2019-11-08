# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "capistrano-faster-rails"
  spec.version       = "1.0.0"
  spec.authors       = ["lifuzhong"]
  spec.email         = ["lifuzho@126.com"]

  spec.summary       = %q{Speedup deploy Ruby On Rails project when using capistrano}
  spec.description   = %q{
    1. Capistrano runs each command separately on their own SSH session and that's why it takes so long to deploy an application, copy `linked_files` and `linked_dirs` with one command will speedup deploying process.
    2. `bundle install` takes few or dozens of seconds. generally, you don't have to execute `bundle install` if your Gemfile and Gemfile.lock not changed
    3. `rake assets:precompile` is really slow if your Rails project has plenty of assets to precompile, even if they are not changed. You don't have to precompile them if not chagned.
  }
  spec.homepage      = "https://github.com/ifool/capistrano-faster-rails"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/ifool/capistrano-faster-rails"
    spec.metadata["changelog_uri"] = "https://github.com/ifool/capistrano-faster-rails"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
