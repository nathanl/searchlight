require 'spec_helper'

describe Searchlight::Options do

  let(:mod) { described_class }

  describe "checked?" do

    {
      true      => true,
      "true"    => true,
      "yeppers" => true,
      1         => true,
      "1"       => true,
      15        => true,
      false     => false,
      nil       => false,
      "false"   => false,
      0         => false,
      "0"       => false,
      ""        => false,
      " "       => false,
    }.each do |input, output|

      it "checked?(#{input.inspect}) is #{output.inspect}" do
        expect(mod.checked?(input)).to eq(output)
      end

    end

  end

  describe "empty?" do
    [ nil, "", "   ", "  \n\t  \r ", "　", "\u00a0", [], {} ].each do |blank_val|

      it "empty?(#{blank_val.inspect}) is true" do
        expect(mod.empty?(blank_val)).to eq(true)
      end

    end

    [Object.new, true, false, 0, 1, "a", { nil => nil }].each do |present_val|

      it "empty?(#{present_val.inspect}) is false" do
        expect(mod.empty?(present_val)).to eq(false)
      end

    end

  end

  describe "excluding empties" do

    it "removes empty values at the top level of the hash" do
      # Simulate something like HashWithIndifferentAccess
      relations = FancyHash.new
      relations[:uncle] = "Jimmy"
      relations[:aunt] = nil

      expect(
        mod.excluding_empties(
          name: "Bob",
          age: nil,
          likes: ["pizza", "fish"],
          dislikes: [],
          elvish: false,
          relations: relations,
          enemies: {},
        )
      ).to eq(
        name: "Bob",
        likes: ["pizza", "fish"],
        relations: {uncle: "Jimmy"},
        elvish: false,
      )
    end

    # Because I don't expect such structures in form parameters.
    # If I'm wrong, this can be changed to be recursive.
    it "does not remove empty values from more deeply-nested elements" do
      expect(
        mod.excluding_empties(
          tags: ["one", "two", "", nil, "three", ["a", "", nil, "b"], {a: ""}],

        )
      ).to eq(
        tags: ["one", "two", "three", ["a", "", nil, "b"], {a: ""}],
      )
    end

    it "does not modify the incoming hash" do
      build_options_hash = proc {
        {
          name: "Bob",
          age: nil,
          likes: ["pizza", "fish", ""],
          dislikes: [],
          elvish: false,
          relations: {uncle: "Jimmy", foo: nil},
          eh: {},
        }
      }
      examples = Array.new(2) { build_options_hash.call }
      mod.excluding_empties(examples[0])
      expect(examples[0]).to eq(examples[1])
    end

  end

end
