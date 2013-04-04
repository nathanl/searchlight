module Named
  module Naming
    attr_accessor :name

    def inspect_object_id
      "0x00%x" % (object_id << 1)
    end
  end

  class Module < ::Module
    include Naming

    def initialize(name, &block)
      super(&block)
      self.name = name
    end

    # @returns [String] NamedModule:CustomName:123456789
    def to_s
      [self.class.name, name, inspect_object_id].join(':')
    end
  end

  module Class
    include Naming

    def self.new(name, superclass = Object, &block)
      ::Class.new(superclass, &block).tap do |klass|
        klass.extend(ClassMethods)
        klass.send(:include, self)
        klass.name = name
      end
    end

    module ClassMethods
      include Naming

      def to_s
        [Named::Class, superclass, name, inspect_object_id].join(':')
      end
    end

    # implementation from: http://stackoverflow.com/a/2818916/4376
    def to_s
      "#<#{self.class}:#{inspect_object_id}>".sub(":#{self.class.inspect_object_id}", '')
    end
  end
end
