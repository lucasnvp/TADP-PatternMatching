require_relative 'matcher_functions'
require_relative 'combinators'

# Matcher
class Matcher
  include Combiators

  def initialize(object, &block)
    @object = object
    @block = block
  end

  def call(object_to_match, context = nil)
    @block.call(@object, object_to_match, context)
  end

end
