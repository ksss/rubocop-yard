# frozen_string_literal: true

require_relative "lib/rubocop/yard/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-yard"
  spec.version = RuboCop::YARD::VERSION
  spec.authors = ["ksss"]
  spec.email = ["co000ri@gmail.com"]

  spec.summary = "Check yardoc format."
  spec.description = "Check yardoc format like tag type."
  spec.homepage = "https://github.com/ksss/rubocop-yard"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::YARD::Plugin'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    [
      %w[CODE_OF_CONDUCT.md LICENSE.txt README.md CHANGELOG.md],
      Dir.glob("lib/**/*.rb").grep_v(/_test\.rb\z/),
      Dir.glob("sig/**/*.rbs"),
      Dir.glob("config/*")
    ].flatten
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'lint_roller'
  spec.add_runtime_dependency 'rubocop', "~> 1.72"
  spec.add_runtime_dependency 'yard'
end

