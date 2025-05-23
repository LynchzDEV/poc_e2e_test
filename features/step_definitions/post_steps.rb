Given('I am on the posts page') do
  visit posts_path
end

When('I click {string}') do |link_text|
  click_link link_text
end

When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I check {string}') do |checkbox|
  check checkbox
end

When('I click {string}') do |button_text|
  click_button button_text
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

Given('there is a published post titled {string}') do |title|
  Post.create!(title: title, content: "Test content", published: true)
end

Given('there is a draft post titled {string}') do |title|
  Post.create!(title: title, content: "Test content", published: false)
end

When('I visit the posts page') do
  visit posts_path
end
