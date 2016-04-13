require "rails_helper"

feature "user creates article" do
  scenario "user correctly fills out form" do
    visit root_path

    within ".new_article" do
      fill_in "Title", with: "Dad sayings"
      fill_in "Body", with: "Don't make me turn this car around!"
      click_button "Create Article"
    end

    expect(page).to have_content("Article saved!")

    expect(page).to have_content "Dad sayings"
    expect(page).to have_content "Don't make me turn this car around!"
  end

  scenario "user incorrectly fills out form" do
    visit root_path

    within ".new_article" do
      click_button "Create Article"
    end

    expect(page).to have_content("Article not saved!")
  end
end
