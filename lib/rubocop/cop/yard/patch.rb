# frozen_string_literal: true

# Support for rubocop v1.46.0 or under.
# see also https://github.com/rubocop/rubocop/pull/11630
return if defined? RuboCop::Ext::Comment

module RuboCop
  module Ext
    # Extensions to `Parser::Source::Comment`.
    module Comment
      def source
        loc.expression.source
      end

      def source_range
        loc.expression
      end
    end
  end
end

Parser::Source::Comment.include RuboCop::Ext::Comment
