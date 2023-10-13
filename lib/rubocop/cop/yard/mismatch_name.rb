# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example mismatch name
      #   # bad
      #   # @param [void] baz
      #   # @option opt aaa [void]
      #   def foo(bar, opts = {})
      #   end
      #
      #   # good
      #   # @param [void] bar
      #   # @param [Array] arg
      #   # @option opts aaa [void]
      #   def foo(bar, opts = {}, *arg)
      #   end
      class MismatchName < Base
        include YARD::Helper
        include RangeHelp
        include DocumentationComment

        def on_def(node)
          return unless node.arguments?

          preceding_lines = preceding_lines(node)
          return false unless preceding_comment?(node, preceding_lines.last)

          yard_docstring = preceding_lines.map { |line| line.text.gsub(/\A#\s*/, '') }.join("\n")
          docstring = begin
            ::YARD::DocstringParser.new.parse(yard_docstring)
          rescue
            return false
          end

          return false if include_overload_tag?(docstring)

          each_tags_by_docstring(['param', 'option'], docstring) do |tags|
            tags.each_with_index do |tag, i|
              comment = find_by_tag(preceding_lines, tag, i)
              next unless comment

              # YARD::Tags::RefTagList is not has name and types
              next if tag.instance_of?(::YARD::Tags::RefTagList)

              types = extract_tag_types(tag)
              unless tag.name && types
                if tag.name.nil?
                  add_offense(comment, message: "No tag name is supplied in `@#{tag.tag_name}`")
                elsif types.nil?
                  add_offense(comment, message: "No types are associated with the tag in `@#{tag.tag_name}`")
                end

                next
              end

              next unless node.arguments.none? { |arg_node| tag.name.to_sym == arg_node.name }

              begin
                parse_type(types.join(', '))
              rescue SyntaxError
                next
              end

              add_offense_to_tag(comment, tag)
            end
          end
        end
        alias on_defs on_def

        private

        def each_tags_by_docstring(tag_names, docstring)
          tag_names.each do |tag_name|
            yield docstring.tags.select { |tag| tag.tag_name == tag_name }
          end
        end

        def find_by_tag(preceding_lines, tag, i)
          count = -1
          preceding_lines.find do |line|
            count += 1 if line.text.include?("@#{tag.tag_name}")
            count == i
          end
        end

        def add_offense_to_tag(comment, tag)
          tag_name_regexp = Regexp.new("\\b#{Regexp.escape(tag.name)}\\b")
          start_column = comment.source.index(tag_name_regexp)
          offense_start = comment.location.column + start_column
          offense_end = offense_start + tag.name.length - 1
          range = source_range(processed_source.buffer, comment.location.line, offense_start..offense_end)
          add_offense(range, message: "`#{tag.name}` is not found in method arguments")
        end

        def include_overload_tag?(docstring)
          docstring.tags.any? { |tag| tag.tag_name == "overload" }
        end
      end
    end
  end
end
