class MockRelation
  def method_missing(method, *args, &block)
    tap { called_methods << method }
  end

  def called_methods
    @called_methods ||= []
  end
end
