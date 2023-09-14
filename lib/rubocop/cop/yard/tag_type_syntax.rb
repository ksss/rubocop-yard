# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example
      #   # bad
      #   @param [Integer String]
      #
      #   # bad
      #   @return [TrueClass|FalseClass]
      #
      #   # good
      #   @param [Integer, String]
      #
      #   # good
      #   @return [Boolean]
      class TagTypeSyntax < Base
        MSG = 'SyntaxError as YARD tag type'
        include RangeHelp # @return [void,]

        def on_new_investigation
          processed_source.comments.each do |comment|
            next if inline_comment?(comment)
            next unless include_yard_tag?(comment)

            check(comment)
          end
        end

        private

        def check(comment)
          docstring = comment.text.gsub(/\A#\s*/, '')
          ::YARD::DocstringParser.new.parse(docstring).tags.each do |tag|
            ::YARD::Tags::TypesExplainer::Parser.parse(tag.types.join(', '))
          rescue SyntaxError
            add_offense(tag_range(comment))
          end
        end

        def inline_comment?(comment)
          !comment_line?(comment.source_range.source_line)
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return)\s+\[.*\]/)
        end

        def tag_range(comment)
          start_column = comment.source.index(/\[/) + 1
          end_column = comment.source.index(/\]/)
          offense_start = comment.location.column + start_column
          offense_end = comment.location.column + end_column
          source_range(processed_source.buffer, comment.location.line, offense_start..offense_end)
        end
      end
    end
  end
end
