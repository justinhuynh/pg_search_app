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
end
