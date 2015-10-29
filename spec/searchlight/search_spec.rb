require 'spec_helper'

describe Searchlight::Search do

  let(:raw_options) {
    {
      title_like: "Mere Christianity",
      "author_name_like" => "Lew",
      category_in: nil,
      tags: ["", "fancy"],
      book_thickness: "smallish",
      parts_about_lolcats: "",
    }
  }
  let(:search) { BookSearch.new(raw_options) }

  describe "initialization" do

    it "doesn't require options" do
      expect(BookSearch.new.results).to eq(BookSearch.new({}).results)
    end

    it "blows up if there is a string/symbol key conflict" do
      expect {
        described_class.new(a: 1, "a" => 2)
      }.to raise_error(
        ArgumentError, %Q{more than one key converts to these string values: ["a"]}
      )
    end

  end

  describe "parsing options" do

    it "makes the raw options available" do
      expect(search.raw_options).to equal(raw_options)
    end

    it "returns only useful values as `options`" do
      expect(search.options).to eq(
        title_like: "Mere Christianity",
        "author_name_like" => "Lew",
        book_thickness: "smallish",
        in_print: "either",
        tags: ["fancy"],
      )
    end

    it "knows which of the `options` have matching search_ methods" do
      expect(search.options_with_search_methods).to eq(
        title_like: "search_title_like",
        "author_name_like" => "search_author_name_like",
        in_print: "search_in_print",
      )
    end
  end

  describe "option readers" do

    it "has an option reader method for each search method, which can read strings or symbols" do
      expect(search.author_name_like).to eq("Lew")
      expect(search.title_like).to eq("Mere Christianity")
      expect(search.board_book).to eq(nil)
      expect{search.book_thickness}.to raise_error(NoMethodError)
      expect{search.not_an_option}.to raise_error(NoMethodError)
    end

  end

  describe "querying" do

    it "builds results by running all methods matching its options" do
      expect(search).to receive(:search_title_like).and_call_original
      expect(search).to receive(:search_author_name_like).and_call_original
      expect(search.results.called_methods).to eq([:all, :order, :merge, :joins, :merge])
    end

    it "only runs the search once" do
      expect(search).to receive(:run).once.and_call_original
      2.times { search.results }
    end

  end

  it "has an 'explain' method to show how it builds its query" do
    expect(search.explain).to eq(
      %Q{
Initialized with `raw_options`: [:title_like, "author_name_like", :category_in, :tags, :book_thickness, :parts_about_lolcats]

Of those, the non-blank ones are available as `options`: [:title_like, "author_name_like", :tags, :book_thickness, :in_print]

Of those, the following have corresponding `search_` methods: [:title_like, "author_name_like", :in_print]. These would be used to build the query.

Blank options are: [:category_in, :parts_about_lolcats]

Non-blank options with no corresponding `search_` method are: [:tags, :book_thickness]
      }.strip
    )
  end

end
