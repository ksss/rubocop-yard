# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example
      #   # bad
      #   @param [Integer String]
      #
      #   # bad
      #   @param [Hash<Symbol, String>]
      #
      #   # bad
      #   @param [Hash(String)]
      #
      #   # bad
      #   @param [Array{Symbol => String}]
      #
      #   # good
      #   @param [Integer, String]
      #
      #   # good
      #   @param [<String>]
      #   @param [Array<String>]
      #
      #   # good
      #   @param [(String)]
      #   @param [Array(String)]
      #
      #   # good
      #   @param [{KeyType => ValueType}]
      #   @param [Hash{KeyType => ValueType}]
      class TagTypeSyntax < Base
        MSG = ''
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
            ::YARD::Tags::TypesExplainer::Parser.parse(tag.types.join(', ')).each do |types_explainer|
              check_mismatch_collection_type(comment, types_explainer)
            end
          rescue SyntaxError
            add_offense(tag_range_for_comment(comment), message: 'SyntaxError as YARD tag type')
          end
        end

        def check_mismatch_collection_type(comment, types_explainer)
          case types_explainer
          when ::YARD::Tags::TypesExplainer::HashCollectionType
            if types_explainer.name == 'Hash'
              types_explainer.key_types.each { |t| check_mismatch_collection_type(comment, t) }
              types_explainer.value_types.each { |t| check_mismatch_collection_type(comment, t) }
            else
              message = "`{KeyType => ValueType}` is the hash collection type syntax. #{did_you_mean_type(types_explainer.name)}"
              add_offense(tag_range_for_comment(comment), message: message)
            end
          when ::YARD::Tags::TypesExplainer::FixedCollectionType
            if types_explainer.name == 'Array'
              types_explainer.types.each { |t| check_mismatch_collection_type(comment, t) }
            else
              message = "`(Type)` is the fixed collection type syntax. #{did_you_mean_type(types_explainer.name)}"
              add_offense(tag_range_for_comment(comment), message: message)
            end
          when ::YARD::Tags::TypesExplainer::CollectionType
            if types_explainer.name == 'Array'
              types_explainer.types.each { |t| check_mismatch_collection_type(comment, t) }
            else
              message = "`<Type>` is the collection type syntax. #{did_you_mean_type(types_explainer.name)}"
              add_offense(tag_range_for_comment(comment), message: message)
            end
          end
        end

        def did_you_mean_type(name)
          case name
          when 'Hash'
            'Did you mean `{KeyType => ValueType}` or `Hash{KeyType => ValueType}`'
          when 'Array'
            'Did you mean `<Type>` or `Array<Type>`'
          else
            ''
          end
        end

        def inline_comment?(comment)
          !comment_line?(comment.source_range.source_line)
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return)\s+\[.*\]/)
        end

        def tag_range_for_comment(comment)
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
