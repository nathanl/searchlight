require "spec_helper"

describe "Searchlight::Adapters::ActionView", type: :feature do

  let(:view)   { ::ActionView::Base.new }
  let(:search) { BookSearch.new("title_like" => "Love Among the Chickens") }

  before :all do
    # Only required when running these tests
    require "searchlight/adapters/action_view"
    BookSearch.send(:include, Searchlight::Adapters::ActionView)
  end

  before :each do
    allow(view).to receive(:protect_against_forgery?).and_return(false)
  end

  it "it can be used to build a form" do
    form = view.form_for(search, url: '#') do |f|
      f.text_field(:title_like)
    end

    expect(form).to have_selector(
      "form input[name='book_search[title_like]'][value='Love Among the Chickens']"
    )
  end

  it "tells the form that it is not persisted" do
    expect(search).not_to be_persisted
  end

end
