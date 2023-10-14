class Foo
  # @param [void] bar
  # @param
  # @param aaa
  # @param [void]
  # @option opt aaa [void]
  # @option opts aaa
  # @option opts aaa [void]
  # @param [void]
  # @param (see #route_docs)
  # @param [Hash<Symbol=>Object] config Hash containing optional configuration
  # @return [void]
  # @return [void] fooo
  def foo(bar, opts = {})
  end

  # @param [String] strings
  def bar(strings, opts = {}, a = nil, *rest, **kw)
  end

  def empty_doc(arg)
  end
end
