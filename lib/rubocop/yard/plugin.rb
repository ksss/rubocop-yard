# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module YARD
    # A plugin that integrates RuboCop Performance with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-yard',
          version: VERSION,
          homepage: 'https://github.com/ksss/rubocop-yard',
          description: 'Check yardoc format like tag type.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end
    end
  end
end
