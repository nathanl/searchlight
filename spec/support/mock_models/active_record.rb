class MockActiveRecord < MockModel

  def self.ancestors
    super + [::ActiveRecord::Base]
  end

  def self.is_a?(thing)
    thing == ::ActiveRecord::Base ? true : super
  end

end

class MockActiveRecordRelation < MockRelation

  def is_a?(thing)
    thing == ::ActiveRecord::Relation ? true : super
  end

  def engine
    MockActiveRecord
  end

end