# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example common
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
      #   # @param [Hash{Symbol => String}]
      #
      #   # good
      #   # @param [Array(String)]
      #
      #   # good
      #   # @param [Hash{Symbol => String}]
      class CollectionType < Base
        include YARD::Helper
        include RangeHelp
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        def on_new_investigation
          processed_source.comments.each do |comment|
            next if inline_comment?(comment)
            next unless include_yard_tag?(comment)

            docstring = ::YARD::DocstringParser.new.parse(comment.text.gsub(/\A#\s*/, ''))
            check_mismatch_collection_type(comment, docstring)
          end
        end

        private

        def check_mismatch_collection_type(comment, docstring)
          each_types_explainer(docstring) do |_type, types_explainer|
            check_mismatch_collection_type_one(comment, types_explainer)
          end
        end

        def check_mismatch_collection_type_one(comment, types_explainer)
          case types_explainer
          when ::YARD::Tags::TypesExplainer::HashCollectionType
            case types_explainer.name
            when 'Hash'
              types_explainer.key_types.each { |t| check_mismatch_collection_type_one(comment, t) }
              types_explainer.value_types.each { |t| check_mismatch_collection_type_one(comment, t) }
            when 'Array'
              message = "`{KeyType => ValueType}` is the Hash collection type syntax."
              add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                types_explainer.name = "Hash"
                correct_tag_type(corrector, comment, types_explainer)
              end
            end
          when ::YARD::Tags::TypesExplainer::FixedCollectionType
            case types_explainer.name
            when 'Hash'
              if types_explainer.types.length == 2
                message = "`Hash(Key, Value)` is miswritten of `Hash<Key, Value>` in perhaps"
                add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                  hash_type = ::YARD::Tags::TypesExplainer::HashCollectionType.new(
                    'Hash',
                    [types_explainer.types[0]],
                    [types_explainer.types[1]]
                  )
                  correct_tag_type(corrector, comment, hash_type)
                end
              else
                message = "`(Type)` is the fixed collection type syntax."
                add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                  types_explainer.name = "Array"
                  correct_tag_type(corrector, comment, types_explainer)
                end
              end
            when 'Array'
              types_explainer.types.each { |t| check_mismatch_collection_type_one(comment, t) }
            end
          when ::YARD::Tags::TypesExplainer::CollectionType
            case types_explainer.name
            when 'Hash'
              if types_explainer.types.length == 2
                message = "`Hash<Key, Value>` is ambiguous syntax"
                add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                  hash_type = ::YARD::Tags::TypesExplainer::HashCollectionType.new(
                    'Hash',
                    [types_explainer.types[0]],
                    [types_explainer.types[1]]
                  )
                  correct_tag_type(corrector, comment, hash_type)
                end
              else
                message = "`<Type>` is the collection type syntax."
                add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                  types_explainer.name = "Array"
                  correct_tag_type(corrector, comment, types_explainer)
                end
              end
            when 'Array'
              types_explainer.types.each { |t| check_mismatch_collection_type_one(comment, t) }
            end
          end
        end

        def correct_tag_type(corrector, comment, types_explainer)
          corrector.replace(comment, comment.source.sub(/\[(.*)\]/) { "[#{styled_string(types_explainer)}]" })
        end

        def inline_comment?(comment)
          !comment_line?(comment.source_range.source_line)
        end

        def include_yard_tag?(comment)
          comment.source.match?(/@(?:param|return|option|raise|yieldparam|yieldreturn)\s+.*\[.*\]/)
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
