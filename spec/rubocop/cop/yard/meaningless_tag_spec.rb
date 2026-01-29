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
end
