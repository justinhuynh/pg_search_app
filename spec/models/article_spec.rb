require "rails_helper"

describe Article do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }

  describe ".search_by_title_and_body" do
    let!(:articles_not_matching) { create_list(:article, 2) }
    let!(:article_title_matches) { create(:article, title: "Tom Brady") }
    let!(:article_body_matches) { create(:article, body: "Tom Brady") }
    let(:query) { "Brady" }

    it "should return articles whose title matches the query" do
      article_results = Article.search_by_title_and_body(query)
      expect(article_results).to include(article_title_matches, article_body_matches)
      expect(article_results).to_not include(*articles_not_matching)
    end
  end

  describe ".search" do
    let!(:articles_not_matching) { create_list(:article, 2) }
    let!(:article_title_matches) { create(:article, title: "Tom Brady") }
    let!(:article_body_matches) { create(:article, body: "Tom Brady") }

    context "has query" do
      let(:query) { "Brady" }
      it "should return articles whose title and/or body matches" do
        article_results = Article.search(query)
        expect(article_results).to include(article_title_matches, article_body_matches)
        expect(article_results).to_not include(*articles_not_matching)
      end
    end

    context "has no query" do
      let(:query) { nil }
      it "should all articles" do
        all_articles = articles_not_matching + [article_title_matches, article_body_matches]
        article_results = Article.search(query)
        expect(article_results).to include(*all_articles)
      end
    end
  end
end
