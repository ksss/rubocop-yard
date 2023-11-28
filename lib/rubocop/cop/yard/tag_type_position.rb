# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      class TagTypePosition < Base
        include YARD::Helper
        include RangeHelp

        def on_new_investigation
          processed_source.comments.each do |comment|
            next if inline_comment?(comment)
            next unless include_yard_tag?(comment)
            next unless include_yard_tag_type?(comment)

            check(comment)
          end
        end

        private

        def check(comment)
          docstring = comment.text.gsub(/\A#\s*/, '')
          ::YARD::DocstringParser.new.parse(docstring).tags.each do |tag|
            types = extract_tag_types(tag)
            if types.nil?
              match = comment.source.match(/(?<type>\[.+\])/)
              add_offense(comment, message: "This docs found `#{match[:type]}`, but parser of YARD can't found types. Please check syntax of YARD.")
            end
          end
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return|option|raise|yieldparam|yieldreturn)\s+.*\[.*\]/)
        end

        def include_yard_tag_type?(comment)
          comment.source.match?(/\[.+\]/)
        end
      end
    end
  end
end
