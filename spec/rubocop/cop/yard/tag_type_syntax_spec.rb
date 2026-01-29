# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::TagTypeSyntax, :config do
  it 'registers offenses for invalid type syntax' do
    expect_offense(<<~RUBY)
      class Foo
        # @param [aaa|bbb] foo
                  ^^^^^^^^ (SyntaxError) invalid character at |
        # @option bar baz [aaa bbb]
                           ^^^^^^^^ (SyntaxError) expecting END, got name 'bbb'
        # @param [Hash<Symbol=>Object] config
                  ^^^^^^^^^^^^^^^^^^^^ (SyntaxError) expecting END, got name 'Object'
        def foo
        end
      end
    RUBY
  end

  it 'does not register an offense for valid syntax' do
    expect_no_offenses(<<~RUBY)
      class Foo
        # @param [String, Integer] foo
        # @param [Hash{Symbol => Object}] bar
        # @return [Array<String>]
        def foo
        end

        def bar
          baz # [inline comment]
        end
      end
    RUBY
  end
end
