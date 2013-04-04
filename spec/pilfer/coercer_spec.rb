require 'spec_helper'

describe Pilfer::Coercer do

  let(:coercer) { described_class }

  describe "boolean" do
    {
      0       => false,
      '0'     => false,
      ''      => false,
      ' '     => false,
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

      it "does NOT coerce nil to a boolean, so that options not supplied are not assumed to be false" do
        expect(coercer.boolean(nil)).to be(nil)
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
