class MockModel

  def self.method_missing(method, *args, &block)
    MockRelation.new(method)
  end
  
end

class MockRelation
  attr_reader :called_methods

  def initialize(called_method)
    @called_methods = [called_method]
  end

  def method_missing(method, *args, &block)
    tap { called_methods << method }
  end
end
