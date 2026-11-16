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
          when ::YARD::Tags::RefTagList
            # A reference tag such as `@param [String] (see #other)` has no types of its own
            nil
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
              next if types.size != types_explainers.size

              types.each_with_index do |type, i|
                block.call(type, types_explainers.fetch(i))
              end
            rescue SyntaxError
            end
          end
        end

        def inline_comment?(comment)
          !comment_line?(comment.source_range.source_line)
        end

        def build_docstring(preceding_lines)
          comment_texts = preceding_lines.map { |l| l.text.gsub(/\A#/, '') }
          minimum_space = comment_texts.map { |t| t.index(/[^\s]/) }.compact.min
          yard_docstring = comment_texts.map { |t| t[minimum_space..-1] }.join("\n")
          begin
            ::YARD::Logger.instance.enter_level(::YARD::Logger::ERROR) do
              ::YARD::DocstringParser.new.parse(yard_docstring)
            end
          rescue
            nil
          end
        end
      end
    end
  end
end
