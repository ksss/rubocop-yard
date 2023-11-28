# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example EnforcedStyle short
      #
      #   # bad
      #   # @param [Hash{KeyType => ValueType}]
      #
      #   # bad
      #   # @param [Array(String)]
      #
      #   # bad
      #   # @param [Array<String>]
      #
      #   # good
      #   # @param [{KeyType => ValueType}]
      #
      #   # good
      #   # @param [(String)]
      #
      #   # good
      #   # @param [<String>]
      #
      # @example EnforcedStyle long (default)
      #   # bad
      #   # @param [{KeyType => ValueType}]
      #
      #   # bad
      #   # @param [(String)]
      #
      #   # bad
      #   # @param [<String>]
      #
      #   # good
      #   # @param [Hash{KeyType => ValueType}]
      #
      #   # good
      #   # @param [Array(String)]
      #
      #   # good
      #   # @param [Array<String>]
      class CollectionStyle < Base
        include YARD::Helper
        include RangeHelp
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        def on_new_investigation
          processed_source.comments.each do |comment|
            next if inline_comment?(comment)
            next unless include_yard_tag?(comment)

            check(comment)
          end
        end

        private

        def check(comment)
          docstring = ::YARD::DocstringParser.new.parse(comment.text.gsub(/\A#\s*/, ''))
          each_types_explainer(docstring) do |type, types_explainer|
            correct_type = styled_string(types_explainer)
            unless ignore_whitespace(type) == ignore_whitespace(correct_type)
              add_offense(comment, message: "`#{type}` is using #{bad_style} style syntax") do |corrector|
                corrector.replace(comment, comment.source.sub(/\[(.*)\]/) { "[#{correct_type}]" })
              end
            end
          end
        end

        def ignore_whitespace(str)
          str.tr(' ', '')
        end

        def bad_style
          if style == :long
            :short
          else
            :long
          end
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return|option|raise|yieldparam|yieldreturn)\s+.*\[.*\]/)
        end
      end
    end
  end
end
