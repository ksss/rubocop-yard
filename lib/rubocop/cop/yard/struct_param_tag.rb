# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # Documents `Struct.new` and `Data.define` members with `@param` tags
      # rather than `@!attribute` directives.
      #
      # YARD reads both, but some tools read only `@param` there, e.g.
      # Solargraph, which types the generated members from them.
      #
      # @example
      #   # bad
      #   # @!attribute name [String]
      #   Person = Struct.new(:name)
      #
      #   # good
      #   # @param name [String]
      #   Person = Struct.new(:name)
      class StructParamTag < Base
        extend AutoCorrector

        MSG = 'Use `@param` instead of `@!attribute` for Struct/Data members.'
        ATTRIBUTE = /\A#\s*@!attribute\b/
        # `@!attribute name [Type] text`, which maps onto `@param` one to one
        CORRECTABLE_ATTRIBUTE = /\A(#\s*)@!attribute(\s+\w+\s+\[)/

        # @!method struct_or_data_definition?(node)
        #   @param node [RuboCop::AST::Node]
        def_node_matcher :struct_or_data_definition?, <<~PATTERN
          (casgn _ _ {
            (block (send (const _ {:Struct :Data}) {:new :define} ...) ...)
            (send (const _ {:Struct :Data}) {:new :define} ...)
          })
        PATTERN

        def on_casgn(node)
          return unless struct_or_data_definition?(node)

          preceding_comments(node).each do |comment|
            next unless comment.text.match?(ATTRIBUTE)

            add_offense(comment) do |corrector|
              next unless comment.text.match?(CORRECTABLE_ATTRIBUTE)

              corrector.replace(comment, comment.text.sub(CORRECTABLE_ATTRIBUTE, '\1@param\2'))
            end
          end
        end

        private

        # The comment block that ends on the line right above the node
        def preceding_comments(node)
          by_line = processed_source.comments.to_h { |comment| [comment.loc.line, comment] }
          line = node.first_line - 1
          comments = []
          while (comment = by_line[line])
            comments.unshift(comment)
            line -= 1
          end
          comments
        end
      end
    end
  end
end
