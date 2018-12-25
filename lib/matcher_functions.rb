require_relative 'exceptions'
require_relative '../lib/_executable_context'

# MatcherFunctions
module MatcherFunctions

  attr_accessor :metches_value

  def val(value)
    Matcher.new(value) do |val, val_to_compare, _context|
      val == val_to_compare
    end
  end

  def type(value)
    Matcher.new(value) do |type_class, class_to_compare, _context|
      class_to_compare.is_a? type_class
    end
  end

  def list(list, match_size = true)
    Matcher.new(list) do |list, list_to_compare, context|
      check_enumerable(list, list_to_compare) &&
        valid_size(list, list_to_compare, match_size) &&
        # reemplazaria el if por esta otra funcion para proponer
        eval_list(list, list_to_compare, context)
    end
  end

  # list solamente
  def check_enumerable(list, list_to_compare)
    list.is_a?(Enumerable) && list_to_compare.is_a?(Enumerable)
  end

  def valid_size(list, list_to_compare, match_size)
    list.size == list_to_compare.size || (!match_size && list.size <= list_to_compare.size)
  end

  # list solamente
  def check_match(pattern, value, context)
    pattern.respond_to?(:call) ? pattern.call(value, context) : val(pattern).call(value)
  end

  # En vez de same_elements? y list_included? se podria tener este eval_list como alternativa
  def eval_list(list, list_to_compare, context)
    list.zip(list_to_compare).map do |value, pattern|
      pattern.nil? || check_match(value, pattern, context)
    end.all?
  end

  def duck(*methods)
    Matcher.new(methods) do |methods, object, _context|
      methods.all? { |method| object.methods.include? method }
    end
  end

  def with(*matchers, &block)
    _hash = Hash.new { |hash, key| hash[key] = [] }
    context = ExcecutableContext.from _hash

    if matchers.all? { |matcher| matcher.call(self, context) }
      if MatcherFunctions.metches_value.nil?
        MatcherFunctions.metches_value = context.instance_eval(&block)
      end
      context.instance_eval &block
    else
      false
    end

  end

  def otherwise
    yield
  end

  def matches?(an_object, &block)
    MatcherFunctions.metches_value = nil
    an_object.instance_eval(&block)
    puts MatcherFunctions.metches_value
    if MatcherFunctions.metches_value.nil?
      return yield
    end
    MatcherFunctions.metches_value
  end

end