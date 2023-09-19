# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example meaningless tag
      #   # bad
      #   # @param [String] foo
      #   # @option bar baz [String]
      #   class Foo
      #
      #   # bad
      #   # @param [String] foo
      #   # @option bar baz [String]
      #   CONST = 1
      #
      #   # good
      #   class Foo
      #
      #   # good
      #   CONST = 1
      class MeaninglessTag < Base
        include RangeHelp
        include DocumentationComment

        def on_class(node)
          check(node)
        end
        alias on_module on_class
        alias on_casgn on_class

        def check(node)
          preceding_lines = preceding_lines(node)
          return false unless preceding_comment?(node, preceding_lines.last)

          yard_docstring = preceding_lines.map { |line| line.text.gsub(/\A#\s*/, '') }.join("\n")
          docstring = ::YARD::DocstringParser.new.parse(yard_docstring)
          docstring.tags.each do |tag|
            next unless tag.tag_name == 'param' || tag.tag_name == 'option'

            comment = preceding_lines.find { |line| line.text.include?("@#{tag.tag_name}") }
            next unless comment

            add_offense(comment, message: "`@#{tag.tag_name}` is meaningless tag on #{node.type}")
          end
        end
      end
    end
  end
end
