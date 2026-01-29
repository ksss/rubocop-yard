# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::TagTypePosition, :config do
  it 'registers offenses when type position is incorrect' do
    expect_offense(<<~RUBY)
      class Foo
        # @param aaa bbb [Integer]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ This docs found `[Integer]`, but parser of YARD can't found types. Please check syntax of YARD.
        # @option [Integer] aaa bbb
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ This docs found `[Integer]`, but parser of YARD can't found types. Please check syntax of YARD.
        def foo
        end
      end
    RUBY
  end

  it 'does not register an offense for correct type position' do
    expect_no_offenses(<<~RUBY)
      class Foo
        # @param [Integer] aaa bbb
        # @option aaa [Integer] bbb
        def foo
        end

        # @param aaa
        # @option bbb
        def bar
        end
      end
    RUBY
  end
end
