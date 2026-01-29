# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::CollectionType, :config do
  context 'when EnforcedStyle is long' do
    let(:cop_config) { { 'EnforcedStyle' => 'long' } }

    it 'registers offenses and autocorrects incorrect collection types' do
      expect_offense(<<~RUBY)
        class Foo
          # @param [Hash(Symbol)]
                    ^^^^^^^^^^^^^ `(Type)` is the fixed collection type syntax.
          # @param [Array{Symbol => String}]
                    ^^^^^^^^^^^^^^^^^^^^^^^^ `{KeyType => ValueType}` is the Hash collection type syntax.
          # @param [Hash(Symbol, String)]
                    ^^^^^^^^^^^^^^^^^^^^^ `Hash(Key, Value)` is miswritten of `Hash<Key, Value>` in perhaps
          # @param [Hash<Symbol, String>]
                    ^^^^^^^^^^^^^^^^^^^^^ `Hash<Key, Value>` is ambiguous syntax
          # @param [Hash<Symbol>]
                    ^^^^^^^^^^^^^ `<Type>` is the collection type syntax.
          def foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # @param [Array(Symbol)]
          # @param [Hash{Symbol => String}]
          # @param [Hash{Symbol => String}]
          # @param [Hash{Symbol => String}]
          # @param [Array<Symbol>]
          def foo
          end
        end
      RUBY
    end

    it 'does not register an offense for correct syntax' do
      expect_no_offenses(<<~RUBY)
        class Foo
          # @param [Hash{Symbol => String}]
          # @param [Array(String)]
          # @param [Array<String>]
          # @param [Range<Integer>]
          # @param [Dict{Symbol => String}]
          def foo
          end
        end
      RUBY
    end

    it 'handles deeply nested types' do
      expect_offense(<<~RUBY)
        class Foo
          # @param [Hash<Symbol, {Symbol => Range<Integer>}>]
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Hash<Key, Value>` is ambiguous syntax
          def foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # @param [Hash{Symbol => Hash{Symbol => Range<Integer>}}]
          def foo
          end
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is short' do
    let(:cop_config) { { 'EnforcedStyle' => 'short' } }

    it 'registers offenses and autocorrects to short style' do
      expect_offense(<<~RUBY)
        class Foo
          # @param [Hash(Symbol)]
                    ^^^^^^^^^^^^^ `(Type)` is the fixed collection type syntax.
          # @param [Array{Symbol => String}]
                    ^^^^^^^^^^^^^^^^^^^^^^^^ `{KeyType => ValueType}` is the Hash collection type syntax.
          # @param [Hash<Symbol, String>]
                    ^^^^^^^^^^^^^^^^^^^^^ `Hash<Key, Value>` is ambiguous syntax
          def foo
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # @param [(Symbol)]
          # @param [{Symbol => String}]
          # @param [{Symbol => String}]
          def foo
          end
        end
      RUBY
    end
  end
end
