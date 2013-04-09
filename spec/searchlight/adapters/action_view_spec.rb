require 'spec_helper'

describe 'Searchlight::Adapters::ActionView', type: :feature, adapter: true do

  before :all do
    require 'searchlight/adapters/action_view'
    require 'action_view'
  end

  let(:view)   { ::ActionView::Base.new }
  let(:search) { AccountSearch.new(paid_amount: 15) }

  before :each do
    view.stub(:protect_against_forgery?).and_return(false)
  end

  it "it can be used to build a form" do
    form = view.form_for(search, url: '#') do |f|
      f.text_field(:paid_amount)
    end

    expect(form).to have_selector("form input[name='search[paid_amount]'][value='15']")
  end

  it "tells the form that it is not persisted" do
    expect(search).not_to be_persisted
  end

end
