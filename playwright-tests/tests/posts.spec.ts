import { test, expect } from "@playwright/test";
import { DatabaseHelper } from "./helpers/database-helper";

test.describe("Posts Management", () => {
  const uniqueId = Date.now().toString().slice(-6);

  test.beforeEach(async ({ page }) => {
    await page.goto("/posts");
  });

  test.describe("Creating a new post", () => {
    test("allows user to create a published post", async ({ page }) => {
      await page.click("text=New post");

      const postTitle = `Playwright Test Post ${uniqueId}`;

      await page.fill('input[name="post[title]"]', postTitle);
      await page.fill(
        'textarea[name="post[content]"]',
        "This post was created using Playwright",
      );

      await page.check('input[type="checkbox"][name="post[published]"]');
      await page.click('input[type="submit"]');
      await expect(
        page.locator("text=Post was successfully created"),
      ).toBeVisible();

      await expect(page.locator(`text=${postTitle}`).first()).toBeVisible();
    });
  });

  test.describe("Viewing posts", () => {
    test("shows only published posts on index", async ({ page }) => {
      const publishedTitle = `Published via Playwright ${uniqueId}`;
      const draftTitle = `Draft via Playwright ${uniqueId}`;

      await DatabaseHelper.createPost(
        page,
        publishedTitle,
        "This is a published post for testing",
        true,
      );

      await DatabaseHelper.createPost(
        page,
        draftTitle,
        "This is a draft post for testing",
        false,
      );

      await page.goto("/posts");
      await expect(
        page.locator(`text="${publishedTitle}"`).first(),
      ).toBeVisible();

      await expect(page.locator(`text="${draftTitle}"`)).not.toBeVisible();
    });
  });
});
