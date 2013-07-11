require 'spec_helper'

describe NoticeSearcher do

  it "returns an elasticsearch search instance" do
    expect(subject.search).to be_instance_of(Tire::Search::Search)
  end

  it "allows searches / filters to be registered" do
    title_filter = TermFilter.new(:title)

    subject.register title_filter

    expect(subject.registry.first).to eq title_filter
  end

  context 'filters' do

    it "correctly configures facets" do
      subject.register TermFilter.new(:title)
      expect(subject.search.facets[:title]).to be
    end

    it "asks for the filter" do
      filter = TermFilter.new(:title)
      searcher = described_class.new(params_hash)
      searcher.register filter

      filter.should_receive(:filter_for).with(params_hash[:title]).and_return(
        [ bleep: { foo: ['as'] } ]
      )
      searcher.search
    end
  end

  context 'searches' do
    it "dispatches to a registered term search" do
      all_fields = TermSearch.new(:term, :_all)
      searcher = described_class.new(params_hash)
      searcher.register all_fields

      all_fields.should_receive(:query_for).with(params_hash[:term])

      searcher.search
    end
  end
end

def params_hash
  {
    term: 'foo',
    title: 'A title'
  }
end