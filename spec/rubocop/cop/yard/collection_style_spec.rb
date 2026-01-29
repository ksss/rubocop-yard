# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::CollectionStyle, :config do
  context 'when EnforcedStyle is long' do
    let(:cop_config) { { 'EnforcedStyle' => 'long' } }

    it 'registers offenses and autocorrects short style to long style' do
      expect_offense(<<~RUBY)
        class Foo
          # @param [(Symbol)]
          ^^^^^^^^^^^^^^^^^^^ `(Symbol)` is using short style syntax
          # @param [<Symbol>]
          ^^^^^^^^^^^^^^^^^^^ `<Symbol>` is using short style syntax
          # @param [{Symbol => String}]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `{Symbol => String}` is using short style syntax
          def foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # @param [Array(Symbol)]
          # @param [Array<Symbol>]
          # @param [Hash{Symbol => String}]
          def foo
          end
        end
      RUBY
    end

    it 'does not register an offense for long style' do
      expect_no_offenses(<<~RUBY)
        class Foo
          # @param [Array(Symbol)]
          # @param [Array<Symbol>]
          # @param [Hash{Symbol => String}]
          def foo
          end
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is short' do
    let(:cop_config) { { 'EnforcedStyle' => 'short' } }

    it 'registers offenses and autocorrects long style to short style' do
      expect_offense(<<~RUBY)
        class Foo
          # @param [Array(Symbol)]
          ^^^^^^^^^^^^^^^^^^^^^^^^ `Array(Symbol)` is using long style syntax
          # @param [Array<Symbol>]
          ^^^^^^^^^^^^^^^^^^^^^^^^ `Array<Symbol>` is using long style syntax
          # @param [Hash{Symbol => String}]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Hash{Symbol => String}` is using long style syntax
          def foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # @param [(Symbol)]
          # @param [<Symbol>]
          # @param [{Symbol => String}]
          def foo
          end
        end
      RUBY
    end

    it 'does not register an offense for short style' do
      expect_no_offenses(<<~RUBY)
        class Foo
          # @param [(Symbol)]
          # @param [<Symbol>]
          # @param [{Symbol => String}]
          def foo
          end
        end
      RUBY
    end
  end
end
