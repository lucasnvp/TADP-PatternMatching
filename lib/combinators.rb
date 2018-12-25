module Combiators
  def and(*matchers)
    Matcher.new(matchers << self) do |matchers, object_to_compare, _context|
      matchers.all? { |matcher| matcher.call(object_to_compare) }
    end
  end

  def or(*matchers)
    Matcher.new(matchers << self) do |matchers, object_to_compare, _context|
      matchers.any? { |matcher| matcher.call(object_to_compare) }
    end
  end

  def not
    Matcher.new(@object) do |object, object_to_compare, _context|
      !@block.call(object, object_to_compare)
    end
  end
end
