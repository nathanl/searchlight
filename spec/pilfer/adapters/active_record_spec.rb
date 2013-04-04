require 'active_record'
require 'spec_helper'

describe Pilfer::Adapters::ActiveRecord do

  let(:search_class) { Named::Class.new('SearchClass', Pilfer::Search) { search_on MockActiveRecord } }
  let(:search_instance) { search_class.new(elephants: 'yes, please') }

  before :each do
    search_class.searches :elephants
  end

  it "adds search methods to the search class" do
    expect(search_class.new).to respond_to(:elephants_search)
  end

  it "adds elephants_search to the search_methods array" do
    expect(search_class.search_methods).to include('elephants_search')
  end

  it "defines search methods that call where on the search target" do
    search_instance.results
    expect(search_instance.search.called_methods).to eq([:where])
  end

end
