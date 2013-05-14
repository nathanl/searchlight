require 'spec_helper'

describe Searchlight::Search do

  let(:search_class) { Named::Class.new('ExampleSearch', described_class) }
  let(:options) { Hash.new }
  let(:search) { search_class.new(options) }

  describe "initializing" do

    let(:options) { {beak_color: 'mauve'} }

    it "mass-assigns provided options" do
      search_class.searches :beak_color
      expect(search.beak_color).to eq('mauve')
    end

    describe "handling invalid options" do

      let(:options) { {genus: 'Mellivora'} }

      it "raises an error explaining that this search class doesn't search the given property" do
        expect { search }.to raise_error( Searchlight::Search::UndefinedOption, /ExampleSearch.*genus/)
      end

    end

  end

  describe "search_on" do

    context "when an explicit search target was provided" do

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

    context "when no explicit search target was provided" do

      let(:search_class) { Named::Class.new('Namespaced::ExampleSearch', described_class) }

      it "guesses the search class based on its own namespaced class name" do
        expect(search_class.search_target).to eq(Namespaced::Example)
      end

      context "when it can't make a guess as to the search class" do

        let(:search_class) { Named::Class.new('Somekinda::Searchthingy', described_class) }

        it "raises an exception" do
          expect{search_class.search_target}.to raise_error(
            Searchlight::Search::MissingSearchTarget, 
            "No search target provided via `search_on` and Searchlight can't guess one."
          )
        end

      end

      context "when it tries to guess the search class but fails" do
        
        let(:search_class) { Named::Class.new('NonExistentObjectSearch', described_class) }

        it "raises an exception" do
          expect{search_class.search_target}.to raise_error(
            Searchlight::Search::MissingSearchTarget, 
            /No search target.*uninitialized constant.*NonExistentObject/
          )
        end

      end

    end

  end

  describe "search_methods" do

    let(:search_class) {
      Named::Class.new('ExampleSearch', described_class) do
        def search_bees
        end

        def search_bats
        end

        def search_bees
        end
      end
    }

    it "keeps a unique list of the search methods" do
      expect(search.send(:search_methods).map(&:to_s).sort).to eq(['search_bats', 'search_bees'])
    end

  end

  describe "search options" do

    describe "accessors" do

      before :each do
        search_class.searches :foo
        search_class.searches :bar
        search_class.searches :stuff
      end

      it "includes exactly one SearchlightAccessors module for this class" do
        accessors_modules = search_class.ancestors.select {|a| a.name =~ /\ASearchlightAccessors/ }
        expect(accessors_modules.length).to eq(1)
        expect(accessors_modules.first).to be_a(Named::Module)
      end

      it "adds a getter" do
        expect(search).to respond_to(:foo)
      end

      it "adds a setter" do
        expect(search).to respond_to(:foo=)
      end

      it "adds a boolean accessor" do
        expect(search).to respond_to(:foo?)
      end

    end

    describe "accessing search options as booleans" do

      let(:options) { {fishies: fishies} }

      before :each do
        search_class.searches :fishies
      end

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

        describe input.inspect do

          let(:fishies) { input }

          it "becomes boolean #{output}" do
            expect(search.fishies?).to eq(output)
          end

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

    let(:search) { AccountSearch.new(paid_amount: 50, business_name: "Rod's Meat Shack") }

    it "builds a search by calling all of the methods that had values to search" do
      search.results
      expect(search.search.called_methods).to eq(2.times.map { :where })
    end

    it "returns the search" do
      expect(search.results).to eq(search.search)
    end

    it "only runs the search once" do
      search.should_receive(:run).once.and_call_original
      2.times { search.results }
    end

  end

  describe "run" do

    let(:search_class) {
      Named::Class.new('TinyBs', described_class) do
        search_on Object
        searches :bits, :bats, :bots

        def search_bits; end
        def search_bats; end
        def search_bots; end

      end
    }

    let(:search_instance) { search_class.new(bits: ' ', bats: nil, bots: false) }

    it "only runs search methods that have real values to search on" do
      search_instance.should_not_receive(:search_bits)
      search_instance.should_not_receive(:search_bats)
      search_instance.should_receive(:search_bots)
      search_instance.send(:run)
    end

  end

end
