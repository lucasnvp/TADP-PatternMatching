class ExcecutableContext
  def self.from(symbols = {})
    context = self.new
    symbols.each_pair do |sym, value|
      context.add_property(sym.to_s, value)
    end
    context
  end

  def add_property(str, value)
    instance_variable_set("@#{str}", value)
    self.singleton_class.send(:attr_reader, str)
  end
end