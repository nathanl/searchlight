class MockMongoid < MockModel

  def self.include?(thing)
    thing == ::Mongoid::Document ? true : super
  end

end

class MockMongoidCriteria < MockRelation

  def is_a?(thing)
    thing == ::Mongoid::Criteria ? true : super
  end

  def self.include?(thing)
    thing == ::Mongoid::Document ? false : super
  end

end