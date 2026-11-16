# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example tag type
      #   # bad
      #   # @param [Integer String]
      #
      #   # good
      #   # @param [Integer, String]
      class TagTypeSyntax < Base
        include YARD::Helper
        include RangeHelp

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
            types = extract_tag_types(tag) or next

            check_syntax_error(comment) do
              parse_type(types.join(', '))
            end
          end
        end

        def check_syntax_error(comment)
          begin
            yield
          rescue SyntaxError => e
            add_offense(tag_range_for_comment(comment), message: "(#{e.class}) #{e.message}")
          end
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return|option|raise|yieldparam|yieldreturn)\s+.*\[.*\]/)
        end

        def tag_range_for_comment(comment)
          # include_yard_tag? guarantees that the comment has `[...]`
          start_column = comment.source.index(/\[/) or raise "`[` is not found in #{comment.source}"
          end_column = comment.source.index(/\]/) or raise "`]` is not found in #{comment.source}"
          offense_start = comment.location.column + start_column + 1
          offense_end = comment.location.column + end_column
          source_range(processed_source.buffer, comment.location.line, offense_start..offense_end)
        end
      end
    end
  end
end
