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
        # output[key] = value.reject { |v| empty?(v) } # Do not remove empty values in a non-empty Array. FIXME: Make this an option or configurable.
        output[key] = nil if output[key].all?(&:blank?) # If Array is entirely empty (i.e. `nil` or empty Strings only) then remove it.
      end
    end
    output.reject { |_, value| empty?(value) }
  end

end
