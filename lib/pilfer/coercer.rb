module Pilfer
  module Coercer

    def self.boolean(value)
      return nil if value.nil?
      !['0', 'false', ''].include?(value.to_s.strip) 
    end

    def self.integer(value)
      value.to_i
    end

  end
end
