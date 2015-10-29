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

    it "has an option reader method for each search method, which reads string options" do
      expect(search.author_name_like).to eq("Lew")
      expect(search.title_like).to eq(nil) # option key was a symbol - TODO convert them to strings
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
    expect(search.explain).to be_a(String)
  end

end
