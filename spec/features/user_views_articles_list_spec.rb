require "rails_helper"

feature "user sees articles" do
  let!(:articles) { create_list(:article, 2) }

  scenario "user sees list of all the articles" do
    visit root_path

    articles.each do |article|
      expect(page).to have_content article.title
      expect(page).to have_content article.body
    end
  end

  # scenario "user sees articles filtered by query" do
  #   article_that_matches = create(:article, title: "Tom Brady")
  #
  #   visit root_path
  #
  #   fill_in "query", with: "Brady"
  #   click_on "Search"
  #
  #   expect(page).to have_content article_that_matches.title
  #   expect(page).to have_content article_that_matches.body
  #
  #   articles.each do |article|
  #     expect(page).to_not have_content article.title
  #     expect(page).to_not have_content article.body
  #   end
  # end
end
