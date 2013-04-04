require 'spec_helper'

describe Pilfer::Search do

  let(:search_class) { Named::Class.new('SearchClass', described_class) }
  let(:options) { Hash.new }
  let(:search) { search_class.new(options) }

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

    it "makes the search target available to its children" do
      expect(SpiffyAccountSearch.search_target).to be(MockModel)
    end

    it "allows the children to set their own search target" do
      klass = Class.new(SpiffyAccountSearch) { search_on Array }
      expect(klass.search_target).to be(Array)
      expect(SpiffyAccountSearch.search_target).to be(MockModel)
    end

  end

  describe "search_methods" do

    let(:search_class) {
      Named::Class.new('SearchClass', described_class) do
        def bees_search
        end

        def bats_search
        end

        def bees_search
        end
      end
    }

    it "keeps a unique list of the search methods" do
      expect(search_class.search_methods).to eq(Set.new(['bees_search', 'bats_search']))
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

      it "includes a PilferAccessors module" do
        accessors_module = search_class.ancestors.detect {|a| a.name == 'PilferAccessors' }
        expect(accessors_module).to be_a(Named::Module)
      end

    end

    describe "coercing search options" do

      let(:options) { {foo: '1', bar: '0'} }
      let(:coercer) { Pilfer::Coercer }

      before :each do
        search_class.searches :foo, :bar
      end

      describe "using Coercer" do

        before :each do
          search_class.coerces :foo, to: :integer
          search_class.coerces :bar, to: :boolean
        end

        it "coerces integers with integer method" do
          coercer.should_receive(:integer).with('1')
          search.foo
        end

        it "coerces booleans with the boolean method" do
          coercer.should_receive(:boolean).with('0')
          search.bar
        end

        it "includes a PilferCoercions module" do
          accessors_module = search_class.ancestors.detect {|a| a.name == 'PilferCoercions' }
          expect(accessors_module).to be_a(Named::Module)
        end

      end

    end

  end

  describe "search" do

    let(:search) { AccountSearch.new }

    it "is initialized with the search_target" do
      expect(search.search).to eq(MockModel)
    end

  end

  describe "results" do

    let(:search) { AccountSearch.new }

    it "builds a search by calling all of the search methods" do
      search.results
      expect(search.search.called_methods).to eq(4.times.map { :where })
    end

    it "returns the search" do
      expect(search.results).to eq(search.search)
    end

    it "only runs the search once" do
      search.should_receive(:run).once.and_call_original
      2.times { search.results }
    end

  end

end
