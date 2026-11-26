# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::MeaninglessTag, :config do
  it 'registers offenses for @param/@option on non-method definitions' do
    expect_offense(<<~RUBY)
      # @param [void] foo
      ^^^^^^^^^^^^^^^^^^^ `@param` is meaningless tag on module
      module Foo
        # @option aaa bbb
        ^^^^^^^^^^^^^^^^^ `@option` is meaningless tag on class
        class Bar
          # @option ccc ddd
          ^^^^^^^^^^^^^^^^^ `@option` is meaningless tag on casgn
          CONST = 1
        end
      end
    RUBY
  end

  it 'does not register an offense for valid tags' do
    expect_no_offenses(<<~RUBY)
      # @note If `Database` isn't configured, auto-correct will not be available.
      # @example
      #   # bad
      #   something
      class NPlusOneQuery < Base
      end

      class Foo
        # @param [String] bar
        # @option opts [String] :key
        def foo(bar, opts = {})
        end
      end
    RUBY
  end

  it 'does not register an offense for @param on Struct/Data constant assignments' do
    expect_no_offenses(<<~RUBY)
      # @param required_gems [Array<String>]
      # @param helper_modules [Array<String>]
      GemHelpers = Struct.new(:required_gems, :helper_modules, keyword_init: true)

      # @param name [String]
      Point = Data.define(:name)

      # @param x [Integer]
      # @param y [Integer]
      WithBlock = Struct.new(:x, :y) do
        def sum
          x + y
        end
      end
    RUBY
  end

  it 'does not register an offense for @param on classes inheriting from Struct.new/Data.define' do
    expect_no_offenses(<<~RUBY)
      # @param name [String]
      class Person < Data.define(:name)
      end

      # @param x [Integer]
      # @param y [Integer]
      class Point < ::Struct.new(
        :x,
        :y,
        keyword_init: true
      )
        def sum
          x + y
        end
      end
    RUBY
  end

  it 'still registers an offense for @param on classes inheriting from anything else' do
    expect_offense(<<~RUBY)
      # @param name [String]
      ^^^^^^^^^^^^^^^^^^^^^^ `@param` is meaningless tag on class
      class Person < Base
      end
    RUBY
  end

  it 'still registers an offense for @option on Struct/Data constant assignments' do
    expect_offense(<<~RUBY)
      # @option opts [String] :key
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `@option` is meaningless tag on casgn
      GemHelpers = Struct.new(:required_gems, keyword_init: true)
    RUBY
  end
end
