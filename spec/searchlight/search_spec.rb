require 'spec_helper'

describe Searchlight::Search do

  let(:search_class)     { Named::Class.new('ExampleSearch', described_class).tap { |klass| klass.searches *allowed_options } }
  let(:allowed_options)  { Hash.new }
  let(:provided_options) { Hash.new }
  let(:search)           { search_class.new(provided_options) }

  describe "initializing" do

    describe "mass-assigning provided options" do

      let(:allowed_options)  { [:beak_color] }
      let(:provided_options) { {beak_color: 'mauve'} }

      it "mass-assigns provided options" do
        search_class.searches :beak_color
        expect(search.beak_color).to eq('mauve')
      end

    end

    describe "screening options" do

      let(:allowed_options) { [:name, :description, :categories, :nicknames] }

      context "when non-empty options are provided" do

        let(:provided_options) { {name: 'Roy', description: 'Ornry', categories: %w[mammal moonshiner], nicknames: %w[Slim Bubba]} }

        it "adds them to the options accessor" do
          expect(search.options).to eq(provided_options)
        end

      end

      context "when some provided options are empty" do

        let(:provided_options) { {name: 'Roy', description: '', categories: %w[mammal moonshiner], nicknames: []} }

        it "does not add them to the options accessor" do
          expect(search.options).to eq(name: 'Roy', categories: %w[mammal moonshiner])

        end

      end

    end

    describe "handling invalid options" do

      let(:provided_options) { {genus: 'Mellivora'} }

      it "raises an error explaining that this search class doesn't search the given property" do
        expect { search }.to raise_error( Searchlight::Search::UndefinedOption, /ExampleSearch.*genus/)
      end

      context "if the provided option starts with 'search_'" do

        let(:allowed_options)  { [:genus] }

        context "and it looks like a valid search option" do

          let(:provided_options) { {search_genus: 'Mellivora'} }

          it "suggests the option name the user may have meant to provide" do
            expect { search }.to raise_error( Searchlight::Search::UndefinedOption, /ExampleSearch.*genus.*Did you just mean/)
          end

        end

        context "but doesn't look like a valid search option" do

          let(:provided_options) { {search_girth: 'Wee'} }

          it "doesn't suggest an option name" do
            begin
              search
            rescue Searchlight::Search::UndefinedOption => exception
              expect(exception.message.match(/Did you just mean/)).to be_nil
            end
          end

        end

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
            /No search target/
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

      let(:provided_options) { {fishies: fishies} }

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

    let(:search) { AccountSearch.new(paid_amount: 50, business_name: "Rod's Meat Shack", other_attribute: 'whatevs') }

    it "builds a search by calling each search method that corresponds to a provided option" do
      search.should_receive(:search_paid_amount).and_call_original
      search.should_receive(:search_business_name).and_call_original
      # Can't do `.should_not_receive(:search_other_attribute)` because the expectation defines a method which would get called.
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
