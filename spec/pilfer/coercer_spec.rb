require 'spec_helper'

describe Pilfer::Coercer do

  let(:coercer) { described_class }

  describe "boolean" do
    {
      0       => false,
      '0'     => false,
      ''      => false,
      ' '     => false,
      nil     => false,
      'false' => false,
      1       => true,
      '1'     => true,
      15      => true,
      'true'  => true,
      'pie'   => true
    }.each do |input, output|

      it "coerces #{input.inspect} to #{output}" do
        expect(coercer.boolean(input)).to be(output)
      end
    end
  end

  describe "integer" do

    it "uses to_i" do
      input = '10'
      input.should_receive(:to_i)
      coercer.integer(input)
    end

  end

end
