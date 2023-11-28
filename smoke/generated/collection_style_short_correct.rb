class Foo
  # @param [(Symbol)]
  # @param [<Symbol>]
  # @param [{Symbol => String}]
  # @param [(Symbol)]
  # @param [<Symbol>]
  # @param [<<<Symbol>>>]
  # @param [{Symbol => String}]
  # @param [Range<Integer>]
  # @param [Dict{Symbol=>String}]
  # @param [<{Symbol => <Integer>, List<Integer>}>]
  def foo
  end
end

# https://github.com/ksss/rubocop-yard/issues/19
class Test
  # @param [{Symbol => Object}] options The options
  # @option [Integer] :op Option associated to no param
  def test(options)
  end
end
