# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # Renders a type of YARD in the collection style configured by `EnforcedStyle`.
      module StyledString
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
      end
    end
  end
end
