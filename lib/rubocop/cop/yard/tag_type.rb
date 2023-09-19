# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example
      #   # bad
      #   # @param [Integer String]
      #
      #   # bad
      #   # @param [Hash<Symbol, String>]
      #
      #   # bad
      #   # @param [Hash(String)]
      #
      #   # bad
      #   # @param [Array{Symbol => String}]
      #
      #   # good
      #   # @param [Integer, String]
      #
      #   # good
      #   # @param [<String>]
      #   # @param [Array<String>]
      #   # @param [List<String>]
      #   # @param [Array<(String, Fixnum, Hash)>]
      #
      #   # good
      #   # @param [(String)]
      #   # @param [Array(String)]
      #
      #   # good
      #   # @param [{KeyType => ValueType}]
      #   # @param [Hash{KeyType => ValueType}]
      class TagType < Base
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
          check_syntax_error(comment) do
            ::YARD::DocstringParser.new.parse(docstring).tags.each do |tag|
              next unless tag.types

              ::YARD::Tags::TypesExplainer::Parser.parse(tag.types.join(', ')).each do |types_explainer|
                check_mismatch_collection_type(comment, types_explainer)
              end
            end
          end
        end

        def check_syntax_error(comment)
          begin
            yield
          rescue SyntaxError => e
            add_offense(tag_range_for_comment(comment), message: "(#{e.class})a #{e.message}")
          end
        end

        def check_mismatch_collection_type(comment, types_explainer)
          case types_explainer
          when ::YARD::Tags::TypesExplainer::HashCollectionType
            if types_explainer.name == 'Hash'
              types_explainer.key_types.each { |t| check_mismatch_collection_type(comment, t) }
              types_explainer.value_types.each { |t| check_mismatch_collection_type(comment, t) }
            else
              did_you_mean = types_explainer.name == 'Array' ? 'Did you mean `<Type>` or `Array<Type>`' : ''
              message = "`{KeyType => ValueType}` is the hash collection type syntax. #{did_you_mean}"
              add_offense(tag_range_for_comment(comment), message: message)
            end
          when ::YARD::Tags::TypesExplainer::FixedCollectionType
            if types_explainer.name == 'Hash'
              message = "`(Type)` is the fixed collection type syntax. Did you mean `{KeyType => ValueType}` or `Hash{KeyType => ValueType}`"
              add_offense(tag_range_for_comment(comment), message: message)
            else
              types_explainer.types.each { |t| check_mismatch_collection_type(comment, t) }
            end
          when ::YARD::Tags::TypesExplainer::CollectionType
            if types_explainer.name == 'Hash'
              message = "`<Type>` is the collection type syntax. `{KeyType => ValueType}` or `Hash{KeyType => ValueType}` is more good"
              add_offense(tag_range_for_comment(comment), message: message)
            else
              types_explainer.types.each { |t| check_mismatch_collection_type(comment, t) }
            end
          end
        end

        def inline_comment?(comment)
          !comment_line?(comment.source_range.source_line)
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return|option|raise|yieldparam|yieldreturn)\s+\[.*\]/)
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
