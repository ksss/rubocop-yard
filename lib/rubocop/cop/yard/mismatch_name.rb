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
        extend AutoCorrector

        def on_def(node)
          return unless node.arguments?

          preceding_lines = preceding_lines(node)
          return false unless preceding_comment?(node, preceding_lines.last)

          docstring = build_docstring(preceding_lines)
          return false unless docstring

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
              next unless types

              begin
                parse_type(types.join(', '))
              rescue SyntaxError
                next
              end if types

              add_offense_to_tag(node, comment, tag)
            end
          end

          # Documentation only or just `@return` is a common form of documentation.
          # The subsequent features will be limited to cases where both `@param` and `@option` are present.
          unless docstring.tags.find { |tag| (tag.tag_name == 'param' && !(tag.instance_of?(::YARD::Tags::RefTagList) && tag.name.nil?)) || tag.tag_name == 'option' }
            return false
          end
          node.arguments.each do |argument|
            next if argument.type == :blockarg
            next if argument.type == :kwnilarg
            next if !argument.respond_to?(:name) || argument.name.nil?

            found = docstring.tags.find do |tag|
              next unless tag.tag_name == 'param' || tag.tag_name == 'option'
              tag.name&.to_sym == argument.name
            end

            unless found
              comment = preceding_lines.last
              return if part_of_ignored_node?(comment)
              add_offense(comment, message: "This method has argument `#{argument.name}`, But not documented") do |corrector|
                corrector.replace(
                  comment.source_range.end,
                  "#{comment.source_range.end.join(node.source_range.begin).source}# #{tag_prototype(argument)}"
                )
              end
            end
          end
        end
        alias on_defs on_def

        private

        # @param [RuboCop::AST::ArgNode] argument
        def tag_prototype(argument)
          type = case argument.type
                 when :kwrestarg
                   "Hash{Symbol => Object}"
                 when :restarg
                   "Array<Object>"
                 when :optarg, :kwoptarg
                   literal_to_yard_type(argument.children.last)
                 else
                   "Object"
                 end

          case cop_config_prototype_name
          when "before"
            "@param #{argument.name} [#{type}]"
          when "after"
            "@param [#{type}] #{argument.name}"
          end
        end

        def literal_to_yard_type(node)
          case node.type
          when :int
            "Integer"
          when :float
            "Float"
          when :rational
            "Rational"
          when :complex
            "Complex"
          when :str
            "String"
          when :true, :false
            "Boolean"
          when :sym
            "Symbol"
          when :array
            "Array<Object>"
          when :hash
            "Hash{Symbol => Object}"
          when :regexp
            "Regexp"
          when :irange, :erange
            "Range[Object]"
          when :nil
            "Object, nil"
          else
            "Object"
          end
        end

        def cop_config_prototype_name
          @cop_config_prototype_name ||= cop_config["EnforcedStylePrototypeName"].tap do |c|
            unless cop_config["SupportedStylesPrototypeName"].include?(c)
              raise "unsupported style #{c}"
            end
          end
        end

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

        def add_offense_to_tag(node, comment, tag)
          tag_name_regexp = Regexp.new("\\s#{Regexp.escape(tag.name)}\\s")
          start_column = comment.source.index(tag_name_regexp) or return
          offense_start = comment.location.column + start_column
          offense_end = offense_start + tag.name.length - 1
          range = source_range(processed_source.buffer, comment.location.line, offense_start..offense_end)
          argument_names = node.arguments.map(&:name).compact
          argument_name =
            if argument_names.empty?
              ''
            else
              " of [#{argument_names.join(', ')}]"
            end
          add_offense(range, message: "`#{tag.name}` is not found in method arguments#{argument_name}")
          ignore_node(comment)
        end

        def include_overload_tag?(docstring)
          docstring.tags.any? { |tag| tag.tag_name == "overload" }
        end
      end
    end
  end
end
