# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "puma-plugin-stripe"
  spec.version = "1.1.0"
  spec.author = "Zacharias Knudsen"
  spec.email = "z@chari.as"

  spec.summary = "Forward Stripe webhook events to your web server."
  spec.homepage = "https://github.com/zachasme/puma-plugin-stripe"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.add_dependency "puma", ">= 3.0"
  spec.add_dependency "stripe"

  spec.add_development_dependency "rubocop-rails-omakase"
end
