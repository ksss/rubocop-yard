# frozen_string_literal: true

require 'rubocop'

require_relative 'rubocop/yard'
require_relative 'rubocop/yard/version'
require_relative 'rubocop/yard/inject'

RuboCop::Yard::Inject.defaults!

require_relative 'rubocop/cop/yard_cops'
