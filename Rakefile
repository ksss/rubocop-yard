# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: ['smoke:test', :check_default_yml]

task :check_default_yml do
  require 'yaml'
  YAML.safe_load_file('config/default.yml')
end

namespace :smoke do
  task :start_server do
    sh "bundle exec rubocop --restart-server"
  end

  desc "Run testing for smoke files"
  task test: [:start_server] do
    require 'json'

    Dir["smoke/*.rb"].each do |rb_path|
      json_path = rb_path.gsub(/.rb$/, '.json')
      puts "Running #{rb_path} and #{json_path}"
      actual = `bundle exec rubocop --format json #{rb_path}`
      actual_out = JSON.parse(actual).except("metadata")
      expect = File.read(json_path)
      expect_out = JSON.parse(expect).except("metadata")

      unless actual_out == expect_out
        puts '---actual---'
        pp actual_out
        puts '---expect---'
        pp expect_out
        raise "change output `rubocop #{rb_path}` with #{json_path}"
      end
    end
  end

  desc "Regenerate smoke files"
  task regenerate: [:start_server] do
    Dir["smoke/*.rb"].each do |rb_path|
      json_path = rb_path.gsub(/.rb$/, '.json')
      rm json_path
      puts "Generate #{json_path}"
      system("bundle exec rubocop --format json #{rb_path} | jq > #{json_path}")
    end
  end
end

desc 'Generate a new cop with a template'
task :new_cop, [:cop] do |_task, args|
  require 'rubocop'

  cop_name = args.fetch(:cop) do
    warn 'usage: bundle exec rake new_cop[Department/Name]'
    exit!
  end

  generator = RuboCop::Cop::Generator.new(cop_name)

  generator.write_source
  generator.inject_require(root_file_path: 'lib/rubocop/cop/yard_cops.rb')
  generator.inject_config(config_file_path: 'config/default.yml')

  puts generator.todo
end
