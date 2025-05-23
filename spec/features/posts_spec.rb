require 'rails_helper'

RSpec.describe 'Posts Management', type: :feature do
  describe 'Creating a new post' do
    it 'allows user to create a published post' do
      visit posts_path
      click_link 'New post'

      fill_in 'Title', with: 'RSpec Test Post'
      fill_in 'Content', with: 'This post was created using RSpec'
      check 'Published'

      click_button 'Create Post'

      expect(page).to have_content('Post was successfully created')
      expect(page).to have_content('RSpec Test Post')
    end
  end

  describe 'Viewing posts' do
    let!(:published_post) { create(:post, title: 'Published via RSpec') }
    let!(:draft_post) { create(:post, :draft, title: 'Draft via RSpec') }

    it 'shows only published posts on index' do
      visit posts_path

      expect(page).to have_content('Published via RSpec')
      expect(page).not_to have_content('Draft via RSpec')
    end
  end
end
