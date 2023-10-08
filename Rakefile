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
  COP_FILE_MAP = {
    'YARD/TagTypeSyntax' => [
      { name: "tag_type_syntax" }
    ],
    'YARD/MeaninglessTag' => [
      { name: "meaningless_tag" }
    ],
    'YARD/MismatchName' => [
      { name: "mismatch_name" }
    ],
    'YARD/CollectionStyle' => [
      { name: "collection_style", style: "long", correct: true },
      { name: "collection_style", style: "short", correct: true },
    ],
    'YARD/CollectionType' => [
      { name: "collection_type", style: "long", correct: true },
      { name: "collection_type", style: "short", correct: true },
    ],
  }
  task :start_server do
    sh "bundle exec rubocop --restart-server"
  end

  desc "Run testing for smoke files"
  task test: [:start_server] do
    require 'json'

    each_config do |cop, content, with_style_name, rb_path, json_path, cmd|
      puts "Running #{rb_path} and #{json_path}"
      actual = `#{cmd} #{rb_path}`
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

      if content[:correct]
        corrected_path = "smoke/generated/#{with_style_name}_correct.rb"
        puts "Running #{corrected_path}"
        actual = `#{cmd} #{corrected_path}`
        unless JSON.parse(actual)["summary"]["offense_count"] == 0
          raise "unexpected autocorrected output #{corrected_path}"
        end
      end
    end
  end

  desc "Regenerate smoke files"
  task regenerate: [:start_server] do
    require 'tempfile'

    each_config do |cop, content, with_style_name, rb_path, json_path, cmd|
      rm json_path rescue nil
      puts "Generate #{json_path}"
      if content[:correct]
        correct_path = "smoke/generated/#{with_style_name}_correct.rb"
        IO.copy_stream(rb_path, correct_path)
        sh("#{cmd} --autocorrect #{correct_path}")
      end
      sh("#{cmd} #{rb_path} | jq > #{json_path}")
    end
  end

  def each_config
    COP_FILE_MAP.each do |cop, contents|
      contents.each do |content|
        with_style = if content[:style]
          "_#{content[:style]}"
        else
          ""
        end
        with_style_name = "#{content[:name]}#{with_style}"
        rb_path = "smoke/#{with_style_name}.rb"
        json_path = "smoke/generated/#{with_style_name}.json"
        cmds = ["bundle", "exec", "rubocop", "--only", cop, "--format", "json"]
        if content[:style]
          cmds << '--config' << "smoke/#{with_style_name}.yml"
        else
          cmds << '--config' << ".rubocop.yml"
        end
        yield [cop, content, with_style_name, rb_path, json_path, cmds.join(' ')]
      end
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
