# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      module Helper
        def extract_tag_types(tag)
          case tag
          when ::YARD::Tags::OptionTag
            tag.pair.types
          when ::YARD::Tags::OverloadTag
            tag.types
          else
            tag.types
          end
        end

        def parse_type(type)
          ::YARD::Tags::TypesExplainer::Parser.parse(type)
        end

        def each_types_explainer(docstring, &block)
          docstring.tags.each do |tag|
            types = extract_tag_types(tag) or next

            begin
              types_explainers = parse_type(types.join(', '))
              types.zip(types_explainers).each do |type, types_explainer|
                block.call(type, types_explainer)
              end
            rescue SyntaxError
            end
          end
        end

        def styled_string(types_explainer)
          case types_explainer
          when ::YARD::Tags::TypesExplainer::HashCollectionType
            tname = case [style, types_explainer.name]
            when [:short, 'Hash']
              ''
            when [:long, 'Hash']
              'Hash'
            else
              types_explainer.name
            end
            "#{tname}{#{types_explainer.key_types.map { styled_string(_1) }.join(', ')} => #{types_explainer.value_types.map { styled_string(_1) }.join(', ')}}"
          when ::YARD::Tags::TypesExplainer::FixedCollectionType
            tname = case [style, types_explainer.name]
            when [:short, 'Array']
              ''
            when [:long, 'Array']
              'Array'
            else
              types_explainer.name
            end
            "#{tname}(#{types_explainer.types.map { styled_string(_1) }.join(', ')})"
          when ::YARD::Tags::TypesExplainer::CollectionType
            tname = case [style, types_explainer.name]
            when [:short, 'Array']
              ''
            when [:long, 'Array']
              'Array'
            else
              types_explainer.name
            end
            "#{tname}<#{types_explainer.types.map { styled_string(_1) }.join(', ')}>"
          when ::YARD::Tags::TypesExplainer::Type
            types_explainer.name
          else
            raise "#{types_explainer.class} is not supported"
          end
        end

        def inline_comment?(comment)
          !comment_line?(comment.source_range.source_line)
        end

        def build_docstring(preceding_lines)
          comment_texts = preceding_lines.map { |l| l.text.gsub(/\A#/, '') }
          minimum_space = comment_texts.map { |t| t.index(/[^\s]/) }.min
          yard_docstring = comment_texts.map { |t| t[minimum_space..-1] }.join("\n")
          begin
            ::YARD::DocstringParser.new.parse(yard_docstring)
          rescue
            nil
          end
        end
      end
    end
  end
end
