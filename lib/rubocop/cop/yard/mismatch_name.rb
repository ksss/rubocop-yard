# frozen_string_literal: true

module RuboCop
  module Cop
    module YARD
      # @example
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
        include RangeHelp
        include DocumentationComment

        def on_def(node)
          return unless node.arguments?

          preceding_lines = preceding_lines(node)
          return false unless preceding_comment?(node, preceding_lines.last)

          yard_docstring = preceding_lines.map { |line| line.text.gsub(/\A#\s*/, '') }.join("\n")
          docstring = ::YARD::DocstringParser.new.parse(yard_docstring)
          docstring.tags.each do |tag|
            next unless tag.tag_name == 'param' || tag.tag_name == 'option'
            next unless node.arguments.none? { |arg_node| tag.name.to_sym == arg_node.name }

            tag_name_regexp = Regexp.new("\\b#{Regexp.escape(tag.name)}\\b")
            comment = preceding_lines.find { |line| line.text.match?(tag_name_regexp) && line.text.include?("@#{tag.tag_name}") }
            next unless comment

            start_column = comment.source.index(tag_name_regexp)
            offense_start = comment.location.column + start_column
            offense_end = offense_start + tag.name.length - 1
            range = source_range(processed_source.buffer, comment.location.line, offense_start..offense_end)
            add_offense(range, message: "`#{tag.name}` is not found in method arguments")
          end
        end
        alias on_defs on_def
      end

      private

      # @param [void] aaa
      # @option opts bbb [void]
      def dummy(aaa, opts = {}, *)
      end
    end
  end
end
