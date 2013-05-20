require 'spec_helper'

describe 'Searchlight::Adapters::ActiveRecord', adapter: true do

  before :all do
    require 'searchlight/adapters/active_record'
    require 'active_record'
  end

  let(:search_class)    {
    Named::Class.new('SearchClass', Searchlight::Search).tap { |klass|
      klass.instance_eval(&ar_version_faker)
      klass.search_on target
    }
  }
  let(:ar_version_faker) { lambda {|klass| nil } } # no-op
  let(:search_instance) { search_class.new(elephants: 'yes, please') }

  shared_examples "search classes with an ActiveRecord target" do

    before :each do
      search_class.searches :elephants
    end

    it "adds search methods to the search class" do
      expect(search_class.new).to respond_to(:search_elephants)
    end

    it "adds search_elephants to the search_methods array" do
      expect(search_instance.send(:search_methods)).to include('search_elephants')
    end

    it "defines search methods that call where on the search target" do
      search_instance.results
      expect(search_instance.search.called_methods).to include(:where)
    end

    it "sets arguments properly in the defined method" do
      search_instance.search.should_receive(:where).with('elephants' => 'yes, please')
      search_instance.search_elephants
    end

  end

  context "when the search target is an ActiveRecord class" do

    let(:target)   { MockActiveRecord }

    describe "converting to an ActiveRecord::Relation" do

      context "for ActiveRecord <= 3" do

        let(:ar_version_faker) { lambda { |klass| klass.stub(:active_record_version).and_return(3) } }

        it "calls 'scoped'" do
          target.should_receive(:scoped)
          search_class
        end

      end

      context "for ActiveRecord >= 4" do

        let(:ar_version_faker) { lambda { |klass| klass.stub(:active_record_version).and_return(4) } }

        it "calls 'all'" do
          target.should_receive(:all)
          search_class
        end

      end

    end

    it_behaves_like "search classes with an ActiveRecord target"

  end

  context "when the search target is an ActiveRecord relation" do

    let(:target)   { MockActiveRecord.joins(:dudes_named_milford).tap { |r| r.called_methods.clear } }

    it_behaves_like "search classes with an ActiveRecord target"

  end

end
