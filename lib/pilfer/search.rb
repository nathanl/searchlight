module Pilfer
  class Search

    def self.searches(*attribute_names)
      include_module "accessors" do
        attr_accessor *attribute_names
      end
    end

    def self.coerces(*attribute_names, options)
      coerce_to = options.fetch(:to) { raise ArgumentError.new "You must provide a :to option" }
      include_module "coersions" do
        attribute_names.each do |attribute_name|
          define_method(attribute_name) do
            coerce(super(), coerce_to)
          end
        end
      end
    end 

    def initialize(options = {})
      options.each { |key, value| public_send("#{key}=", value) }
    end

    private

    # Yes, we really are crazy.  But now your anonymous modules have names!
    # Used so we can allow calling super in sub modules and the base class.
    def self.include_module(module_name, &content)
      mod   = Module.new(&content)
      eigen = class << mod; self; end
      call  = caller.first

      eigen.define_method :to_s do
        "Pilfer::Search #{module_name} (#{call})"
      end
      
      include mod
    end

    def coerce(value, coersion)
      COERCIONS.fetch(coersion).call(value)
    end

    Boolean = Class.new

    COERCIONS = {
      Boolean => proc {|val| !['0', 'false', ''].include?(val.to_s.strip) },
      Integer => proc {|val| val.to_i }
    }
  end
end
