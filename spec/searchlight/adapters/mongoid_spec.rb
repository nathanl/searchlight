require 'spec_helper'

describe 'Searchlight::Adapters::Mongoid', adapter: true do

  before :all do
    require 'mongoid'
    require 'searchlight/adapters/mongoid'
  end

  after :all do
    Object.send(:remove_const, :Mongoid)
  end

  let(:search_class)    {
    Named::Class.new('SearchClass', Searchlight::Search).tap { |klass| klass.search_on target }
  }

  let(:search_instance) { search_class.new(elephants: 'yes, please') }

  shared_examples "search classes with an Mongoid target" do

    context "when the base model has a field matching the search term" do

      before do
        MockMongoid.stub(:fields).and_return('elephants' => 'column info...')
        search_class.searches :elephants
      end

      it "adds search methods to the search class" do
        expect(search_class.new).to respond_to(:search_elephants)
      end

      it "defines search methods that call `where` on the search target" do
        search_instance.results
        expect(search_instance.search.called_methods).to include(:where)
      end

      it "sets arguments properly in the defined method" do
        search_instance.search.should_receive(:where).with('elephants' => 'yes, please')
        search_instance.search_elephants
      end

    end

    context "when the base model has no field matching the search term" do

      before do
        MockMongoid.stub(fields: {})
        search_class.searches :elephants
      end

      it "adds search methods to the search class" do
        expect(search_class.new).to respond_to(:search_elephants)
      end

      it "defines search methods to raise an exception" do
        expect { search_instance.results }.to raise_error(
          Searchlight::Adapters::Mongoid::UndefinedColumn
        )
      end

    end

  end

  context "when the search target is a class with Mongoid::Document module" do

    let(:target)   { MockMongoid }

    it_behaves_like "search classes with an Mongoid target"

  end

  context "when the search target is Mongoid::Criteria class" do

    let(:target)   { MockMongoidCriteria.new([]) }

    before do
      target.stub(klass: MockMongoid)
    end

    it_behaves_like "search classes with an Mongoid target"

  end

end
