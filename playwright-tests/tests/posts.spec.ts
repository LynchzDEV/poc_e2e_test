import { test, expect } from "@playwright/test";
import { DatabaseHelper } from "./helpers/database-helper";

test.describe("Posts Management", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/posts");
  });

  test.describe("Creating a new post", () => {
    test("allows user to create a published post", async ({ page }) => {
      await page.click("text=New post");

      await page.fill('input[name="post[title]"]', "Playwright Test Post");
      await page.fill(
        'textarea[name="post[content]"]',
        "This post was created using Playwright",
      );

      await page.check('input[type="checkbox"][name="post[published]"]');
      await page.click('input[type="submit"]');
      await expect(
        page.locator("text=Post was successfully created"),
      ).toBeVisible();
      await expect(page.locator("text=Playwright Test Post")).toBeVisible();
    });
  });

  test.describe("Viewing posts", () => {
    test("shows only published posts on index", async ({ page }) => {
      await DatabaseHelper.createPost(
        page,
        "Published via Playwright",
        "This is a published post for testing",
        true,
      );

      await DatabaseHelper.createPost(
        page,
        "Draft via Playwright",
        "This is a draft post for testing",
        false,
      );

      await page.goto("/posts");
      await expect(page.locator("text=Published via Playwright")).toBeVisible();
      await expect(page.locator("text=Draft via Playwright")).not.toBeVisible();
    });
  });
});
