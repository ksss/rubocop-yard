class Foo
  # @param [Array(Symbol)]
  # @param [Array<Symbol>]
  # @param [Hash{Symbol => String}]
  # @param [Array(Symbol)]
  # @param [Array<Symbol>]
  # @param [Array<Array<Array<Symbol>>>]
  # @param [Hash{Symbol => String}]
  # @param [Range<Integer>]
  # @param [Dict{Symbol=>String}]
  # @param [Array<Hash{Symbol => Array<Integer>, List<Integer>}>]
  def foo
  end
end

# https://github.com/ksss/rubocop-yard/issues/19
class Test
  # @param [Hash{Symbol=>Object}] options The options
  # @option [Integer] :op Option associated to no param
  def test(options)
  end
end

