# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::StructParamTag, :config do
  it 'registers offenses for @!attribute on Struct.new and Data.define assignments and corrects them to @param' do
    expect_offense(<<~RUBY)
      # A point.
      # @!attribute x [Integer] the abscissa
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `@param` instead of `@!attribute` for Struct/Data members.
      # @!attribute y [Integer]
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `@param` instead of `@!attribute` for Struct/Data members.
      Point = Struct.new(:x, :y, keyword_init: true)

      # @!attribute name [String]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `@param` instead of `@!attribute` for Struct/Data members.
      Person = ::Data.define(:name)
    RUBY

    expect_correction(<<~RUBY)
      # A point.
      # @param x [Integer] the abscissa
      # @param y [Integer]
      Point = Struct.new(:x, :y, keyword_init: true)

      # @param name [String]
      Person = ::Data.define(:name)
    RUBY
  end

  it 'registers an offense for @!attribute on a Struct.new assignment with a block' do
    expect_offense(<<~RUBY)
      # @!attribute x [Integer]
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `@param` instead of `@!attribute` for Struct/Data members.
      Point = Struct.new(:x) do
        def double
          x * 2
        end
      end
    RUBY
  end

  it 'registers an offense but does not correct the directive form with a reader/writer flag' do
    expect_offense(<<~RUBY)
      # @!attribute [r] x
      ^^^^^^^^^^^^^^^^^^^ Use `@param` instead of `@!attribute` for Struct/Data members.
      #   @return [Integer]
      Point = Struct.new(:x)
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense for @param on Struct/Data or @!attribute elsewhere' do
    expect_no_offenses(<<~RUBY)
      # @param x [Integer]
      Point = Struct.new(:x)

      # @!attribute x [Integer]
      CONST = 1

      # @!attribute x [Integer]

      Spaced = Struct.new(:x)

      class Foo
        # @!attribute [r] x
        #   @return [Integer]
        attr_reader :x
      end
    RUBY
  end
end
