require 'spec_helper'
require 'action_view'
require 'pilfer/adapters/action_view'

describe Pilfer::Adapters::ActionView, type: :feature, adapter: true do

  let(:view)   { ::ActionView::Base.new }
  let(:search) { AccountSearch.new(paid_amount: 15) }

  before :each do
    view.stub(:protect_against_forgery?).and_return(false)
  end

  it "it can be used to build a form" do
    form = view.form_for(search, url: '#') do |f|
      f.text_field(:paid_amount)
    end

    expect(form).to have_selector("form input[name='query[paid_amount]'][value='15']")
  end

end
