module Searchlight::Options

  def self.empty?(value)
    return true if value.nil?
    return true if value.respond_to?(:empty?) && value.empty?
    return true if /\A[[:space:]]*\z/ === value
    false
  end

  def self.checked?(value)
    !(['0', 'false', ''].include?(value.to_s.strip))
  end

  def self.excluding_empties(input)
    output = input.dup
    output.each do |key, value|
      if value.is_a?(Hash)
        output[key] = value.reject { |_, v| empty?(v) }
      end
      if value.instance_of?(Array)
        output[key] = value.reject { |v| empty?(v) }
      end
    end
    output.reject { |_, value| empty?(value) }
  end

end
