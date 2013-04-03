require 'spec_helper'

describe Pilfer::Search do

  let(:search_class) { Class.new(described_class) }
  let(:options) { Hash.new }
  let(:search) { search_class.new(options) }
  let(:boolean_type) { described_class.const_get(:Boolean) }
  let(:integer_type) { Integer }

  describe "initializing" do

    let(:options) { {beak_color: 'mauve'} }

    it "mass-assigns provided options" do
      search_class.searches :beak_color
      expect(search.beak_color).to eq('mauve')
    end

  end

  describe "search_on" do

    let(:search_target) { "Bobby Fischer" }

    before :each do
      search_class.search_on search_target
    end

    it "makes the object accessible via `search_target`" do
      expect(search_class.search_target).to eq(search_target)
    end

  end

  describe "search_methods" do

    let(:search_class) {
      Class.new(described_class) do
        def bees_search
        end

        def bats_search
        end
      end
    }

    it "lists the search methods" do
      expect(search_class.search_methods).to eq([:bees_search, :bats_search])
    end

  end

  describe "search options" do

    describe "accessors" do

      before :each do
        search_class.searches :foo
      end

      it "adds a getter" do
        expect(search).to respond_to(:foo)
      end

      it "adds a setter" do
        expect(search).to respond_to(:foo=)
      end

    end

    describe "coercion to" do

      let(:options) { {foo: '1'} }

      before :each do
        search_class.searches :foo
      end

      describe "integer" do

        before :each do
          search_class.coerces :foo, to: integer_type
        end

        it "coerces" do
          expect(search.foo).to be(1)
        end

      end

      describe "boolean" do

        before :each do
          search_class.coerces :foo, to: boolean_type
        end

        it "coerces" do
          expect(search.foo).to be(true)
        end

      end

    end

  end

  describe "searching" do
  end

  describe "coersion procs" do
    let(:coercer) { described_class.const_get(:COERCIONS).fetch(coercion_type) }

    describe "boolean" do
      let(:coercion_type) { boolean_type }

      {
         0      => false,
        '0'     => false,
         ''     => false,
         ' '    => false,
         nil    => false,
        'false' => false,
         1      => true,
        '1'     => true,
         15     => true,
        'true'  => true,
        'pie'   => true
      }.each do |input, output|
        
        it "coerces #{input.inspect} to #{output}" do
          expect(coercer.call(input)).to be(output)
        end
      end
    end

    describe "integer" do
      let(:coercion_type) { integer_type }

      it "coerces to an integer using to_i" do
        foo = '10'
        foo.should_receive(:to_i)
        coercer.call(foo)
      end
    end
  end

end
