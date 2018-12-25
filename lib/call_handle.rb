# Call Handle
module CallHandle
  def call(value, context = nil)
    context.singleton_class.send(:define_method, self) { value }
    true
  end
end

class Symbol
  include CallHandle
end