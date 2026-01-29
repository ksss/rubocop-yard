# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::YARD::MismatchName, :config do
  it 'registers offenses for incomplete or mismatched tags' do
    expect_offense(<<~RUBY)
      class Foo
        # @param
        ^^^^^^^^ No tag name is supplied in `@param`
        def foo(bar)
        end

        # @param aaa
        ^^^^^^^^^^^^ No types are associated with the tag in `@param`
        def bar(bar)
        end

        # @option opt aaa [void]
                 ^^^ `opt` is not found in method arguments of [opts]
        def baz(opts = {})
        end
      end
    RUBY
  end

  it 'autocorrects missing parameter documentation' do
    expect_offense(<<~RUBY)
      class Foo
        # @param [String] strings
        ^^^^^^^^^^^^^^^^^^^^^^^^^ This method has argument `opts`, But not documented
        def bar(strings, opts = {})
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        # @param [String] strings
        # @param [Hash{Symbol => Object}] opts
        def bar(strings, opts = {})
        end
      end
    RUBY
  end

  it 'autocorrects multiple missing parameters with type inference' do
    expect_offense(<<~RUBY)
      class Foo
        # @param [String] strings
        ^^^^^^^^^^^^^^^^^^^^^^^^^ This method has argument `opts`, But not documented
        def bar(strings, opts = {}, a = nil, *rest, **kw)
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        # @param [String] strings
        # @param [Hash{Symbol => Object}] opts
        # @param [Object, nil] a
        # @param [Array<Object>] rest
        # @param [Hash{Symbol => Object}] kw
        def bar(strings, opts = {}, a = nil, *rest, **kw)
        end
      end
    RUBY
  end

  it 'does not register an offense for valid documentation' do
    expect_no_offenses(<<~RUBY)
      class Foo
        # @return [void]
        def return_only(arg)
        end

        def empty_doc(arg)
        end

        # @param (see #other)
        def ref_only(arg)
        end

        # @param [String] arg
        def foo(arg)
        end

        # @param [String] arg
        def rest_block(arg, *, **, &block)
        end

        # @param [String] arg
        def delegate(arg, ...)
        end

        # @param arg1 (see #other)
        # @param [Object] arg2
        def partial_ref(arg1, arg2)
        end

        # @param [String]
        #   arg multiline doc
        def multiline_param(arg)
        end

        # @param text [Array<String>]
        def kwnilarg(text, **nil)
        end
      end
    RUBY
  end
end
