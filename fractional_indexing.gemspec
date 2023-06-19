# frozen_string_literal: true

require_relative "lib/fractional_indexing/version"

Gem::Specification.new do |spec|
  spec.name = "fractional_indexing"
  spec.version = FractionalIndexing::VERSION
  spec.authors = ["Rui Serra"]
  spec.email = ["rui@dooly.ai"]
  spec.licenses = ['CC0-1.0']

  spec.summary = "Fractional index generation based on David Greenspan's Implementing Fractional Indexing article."
  spec.description = "This is a Ruby port of the JavaScript implementation by @rocicorp."
  spec.homepage = "https://github.com/dooly-ai/fractional-indexing"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
