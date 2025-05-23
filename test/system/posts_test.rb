require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  test "creating a new post" do
    visit posts_path

    click_on "New post"
    fill_in "Title", with: "My Test Post"
    fill_in "Content", with: "This is test content"
    check "Published"

    click_on "Create Post"

    assert_text "Post was successfully created"
    assert_text "My Test Post"
  end

  test "viewing published posts" do
    # Create test data
    Post.create!(title: "Published Post", content: "Published content", published: true)
    Post.create!(title: "Draft Post", content: "Draft content", published: false)

    visit posts_path

    assert_text "Published Post"
    refute_text "Draft Post"
  end
end
