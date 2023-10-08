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
      #
      # @example EnforcedStyle short (default)
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
      # @example EnforcedStyle long
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
      class CollectionType < Base
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
          check_mismatch_collection_type(comment, docstring)
          check_style(comment, docstring)
        end

        def check_style(comment, docstring)
          each_types_explainer(docstring) do |type, types_explainer|
            offenced_type = types_explainer.to_s_by_style(style)
            unless type == offenced_type
              add_offense(comment, message: "`#{type}` is using #{bad_style} style syntax") do |corrector|
                corrector.replace(comment, comment.source.sub(/\[(.*)\]/) { "[#{offenced_type}]" })
              end
            end
          end
        end

        def check_mismatch_collection_type(comment, docstring)
          each_types_explainer(docstring) do |_type, types_explainer|
            check_mismatch_collection_type_one(comment, types_explainer)
          end
        end

        def check_mismatch_collection_type_one(comment, types_explainer)
          case types_explainer
          when ::YARD::Tags::TypesExplainer::HashCollectionType
            if types_explainer.name == 'Hash'
              types_explainer.key_types.each { |t| check_mismatch_collection_type_one(comment, t) }
              types_explainer.value_types.each { |t| check_mismatch_collection_type_one(comment, t) }
            else
              message = "`{KeyType => ValueType}` is the Hash collection type syntax."
              add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                types_explainer.name = "Hash"
                correct_tag_type(corrector, comment, types_explainer)
              end
            end
          when ::YARD::Tags::TypesExplainer::FixedCollectionType
            if types_explainer.name == 'Hash'
              message = "`(Type)` is the fixed collection type syntax."
              add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                types_explainer.name = "Array"
                correct_tag_type(corrector, comment, types_explainer)
              end
            else
              types_explainer.types.each { |t| check_mismatch_collection_type_one(comment, t) }
            end
          when ::YARD::Tags::TypesExplainer::CollectionType
            if types_explainer.name == 'Hash'
              message = "`<Type>` is the collection type syntax."
              if types_explainer.types.length == 2
                add_offense(tag_range_for_comment(comment), message: message) do |corrector|
                  hash_type = ::YARD::Tags::TypesExplainer::HashCollectionType.new(
                    'Hash',
                    [types_explainer.types[0]],
                    [types_explainer.types[1]]
                  )
                  correct_tag_type(corrector, comment, hash_type)
                end
              else
                add_offense(tag_range_for_comment(comment), message: message)
              end
            else
              types_explainer.types.each { |t| check_mismatch_collection_type_one(comment, t) }
            end
          end
        end

        def bad_style
          if style == :long
            :short
          else
            :long
          end
        end

        def correct_tag_type(corrector, comment, types_explainer)
          corrector.replace(comment, comment.source.sub(/\[(.*)\]/) { "[#{types_explainer.to_s_by_style(style)}]" })
        end

        def each_types_explainer(docstring, &block)
          docstring.tags.each do |tag|
            types = extract_tag_types(tag)

            begin
              types_explainers = ::YARD::Tags::TypesExplainer::Parser.parse(types.join(', '))
              types.zip(types_explainers).each do |type, types_explainer|
                block.call(type, types_explainer)
              end
            rescue SyntaxError
            end
          end
        end

        def extract_tag_types(tag)
          case tag
          when ::YARD::Tags::OptionTag
            tag.pair.types
          else
            tag.types
          end
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
