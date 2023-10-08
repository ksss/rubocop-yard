class ::YARD::Tags::TypesExplainer::Type
  def to_s_by_style(style = :long)
    name
  end
end

class ::YARD::Tags::TypesExplainer::CollectionType
  def to_s_by_style(style = :long)
    "#{style == :long ? name : ''}<#{types.map { |t| t.to_s_by_style(style) }.join(', ')}>"
  end
end

class ::YARD::Tags::TypesExplainer::FixedCollectionType
  def to_s_by_style(style = :long)
    "#{style == :long ? name : ''}(#{types.map { |t| t.to_s_by_style(style) }.join(', ')})"
  end
end

class ::YARD::Tags::TypesExplainer::HashCollectionType
  def to_s_by_style(style = :long)
    "#{style == :long ? name : ''}{#{key_types.map { |t| t.to_s_by_style(style) }.join(', ')} => #{value_types.map { |t| t.to_s_by_style(style) }.join(', ')}}"
  end
end
