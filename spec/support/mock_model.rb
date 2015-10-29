class MockModel

  def self.method_missing(method, *args, &block)
    MockRelation.new([method])
  end

end

class MockRelation
  attr_reader :called_methods

  def initialize(called_methods)
    @called_methods = called_methods
  end

  def method_missing(method, *args, &block)
    self.class.new(called_methods + [method])
  end
  
  def ==(other)
    other.class == self.class && other.called_methods == called_methods
  end

end

module Namespaced
  class Example
  end
end
