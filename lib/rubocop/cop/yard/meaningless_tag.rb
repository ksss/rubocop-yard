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
      #
      #   # good (Struct/Data constant assignments accept @param)
      #   # @param name [String]
      #   # @param age [Integer]
      #   Person = Struct.new(:name, :age, keyword_init: true)
      class MeaninglessTag < Base
        include YARD::Helper
        include RangeHelp
        include DocumentationComment
        extend AutoCorrector

        # @!method struct_or_data_definition?(node)
        #   @param node [RuboCop::AST::Node]
        def_node_matcher :struct_or_data_definition?, <<~PATTERN
          (casgn _ _ {
            (block (send (const _ {:Struct :Data}) {:new :define} ...) ...)
            (send (const _ {:Struct :Data}) {:new :define} ...)
          })
        PATTERN

        def on_class(node)
          check(node)
        end
        alias on_module on_class
        alias on_casgn on_class

        def check(node)
          preceding_lines = preceding_lines(node)
          return false unless preceding_comment?(node, preceding_lines.last)

          docstring = build_docstring(preceding_lines)
          return false unless docstring

          docstring.tags.each do |tag|
            next unless tag.tag_name == 'param' || tag.tag_name == 'option'
            next if tag.tag_name == 'param' && struct_or_data_definition?(node)

            comment = preceding_lines.find { |line| line.text.include?("@#{tag.tag_name}") }
            next unless comment

            add_offense(comment, message: "`@#{tag.tag_name}` is meaningless tag on #{node.type}") do |corrector|
              corrector.replace(comment, comment.text.gsub("@#{tag.tag_name}", tag.tag_name))
            end
          end
        end
      end
    end
  end
end
