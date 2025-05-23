// playwright-tests/tests/helpers/database-helper.ts
import { Page } from "@playwright/test";

/**
 * Database Helper - Utilities for managing test data
 *
 * This helper provides methods to create, clean, and manage test data
 * for your Rails application during Playwright tests.
 */
export class DatabaseHelper {
  /**
   * Creates a new post through the web interface
   * @param page - Playwright page object
   * @param title - Post title
   * @param content - Post content
   * @param published - Whether the post should be published (default: true)
   */
  static async createPost(
    page: Page,
    title: string,
    content: string,
    published: boolean = true,
  ): Promise<void> {
    await page.goto("/posts/new");
    await page.fill('input[name="post[title]"]', title);
    await page.fill('textarea[name="post[content]"]', content);

    if (published) {
      await page.check('input[type="checkbox"][name="post[published]"]');
    } else {
      await page.uncheck('input[type="checkbox"][name="post[published]"]');
    }

    await page.click('input[type="submit"]');
    await page.waitForSelector("text=Post was successfully created");
  }

  /**
   * Creates multiple posts quickly
   * @param page - Playwright page object
   * @param posts - Array of post objects with title, content, and published status
   */
  static async createMultiplePosts(
    page: Page,
    posts: Array<{ title: string; content: string; published?: boolean }>,
  ): Promise<void> {
    for (const post of posts) {
      await this.createPost(
        page,
        post.title,
        post.content,
        post.published ?? true,
      );
    }
  }

  /**
   * Creates sample blog posts for testing
   * @param page - Playwright page object
   */
  static async createSamplePosts(page: Page): Promise<void> {
    const samplePosts = [
      {
        title: "Getting Started with Rails",
        content:
          "Rails is a powerful web framework for Ruby that makes it easy to build web applications.",
        published: true,
      },
      {
        title: "Introduction to Testing",
        content:
          "Testing is crucial for maintaining code quality and preventing bugs in production.",
        published: true,
      },
      {
        title: "Draft: Future Features",
        content:
          "This post contains ideas for future features that we might implement.",
        published: false,
      },
      {
        title: "Playwright E2E Testing",
        content:
          "End-to-end testing with Playwright provides comprehensive test coverage.",
        published: true,
      },
    ];

    await this.createMultiplePosts(page, samplePosts);
  }

  /**
   * Deletes a post by title (navigates through the UI)
   * @param page - Playwright page object
   * @param title - Title of the post to delete
   */
  static async deletePostByTitle(page: Page, title: string): Promise<void> {
    await page.goto("/posts");
    await page.click(`text=${title}`);

    page.on("dialog", async (dialog) => {
      if (dialog.type() === "confirm") {
        await dialog.accept();
      }
    });

    await page.click("text=Destroy this post");
    await page.waitForSelector("text=Post was successfully destroyed");
  }

  /**
   * Clears all posts (WARNING: This will delete all posts in the test database)
   * This method works by calling a Rails API endpoint or console command
   * @param page - Playwright page object
   */
  static async clearAllPosts(page: Page): Promise<void> {
    await page.goto("/posts");

    const postLinks = await page.locator('a[href*="/posts/"]').count();

    for (let i = 0; i < postLinks; i++) {
      const firstPostLink = page.locator('a[href*="/posts/"]').first();

      if ((await firstPostLink.count()) > 0) {
        await firstPostLink.click();

        page.on("dialog", async (dialog) => {
          if (dialog.type() === "confirm") {
            await dialog.accept();
          }
        });

        const deleteButton = page.locator("text=Destroy this post");
        if ((await deleteButton.count()) > 0) {
          await deleteButton.click();
          await page.waitForURL("/posts");
        } else {
          await page.goto("/posts");
        }
      }
    }
  }

  /**
   * Updates a post by finding it by title
   * @param page - Playwright page object
   * @param originalTitle - Current title of the post
   * @param newTitle - New title for the post
   * @param newContent - New content for the post
   * @param published - New published status
   */
  static async updatePostByTitle(
    page: Page,
    originalTitle: string,
    newTitle: string,
    newContent: string,
    published?: boolean,
  ): Promise<void> {
    await page.goto("/posts");
    await page.click(`text=${originalTitle}`);
    await page.click("text=Edit this post");
    await page.fill('input[name="post[title]"]', newTitle);
    await page.fill('textarea[name="post[content]"]', newContent);

    if (published !== undefined) {
      if (published) {
        await page.check('input[type="checkbox"][name="post[published]"]');
      } else {
        await page.uncheck('input[type="checkbox"][name="post[published]"]');
      }
    }

    await page.click('input[type="submit"]');
    await page.waitForSelector("text=Post was successfully updated");
  }

  /**
   * Gets the total number of posts displayed on the index page
   * @param page - Playwright page object
   * @returns Promise<number> - Number of posts
   */
  static async getPostCount(page: Page): Promise<number> {
    await page.goto("/posts");
    const postElements = await page.locator("tr").count();

    return Math.max(0, postElements - 1);
  }

  /**
   * Verifies that a post exists with the given title
   * @param page - Playwright page object
   * @param title - Title to search for
   * @returns Promise<boolean> - Whether the post exists
   */
  static async postExists(page: Page, title: string): Promise<boolean> {
    await page.goto("/posts");

    try {
      await page.waitForSelector(`text=${title}`, { timeout: 5000 });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Creates test data for performance testing
   * @param page - Playwright page object
   * @param count - Number of posts to create
   */
  static async createManyPosts(page: Page, count: number): Promise<void> {
    console.log(`Creating ${count} test posts...`);

    for (let i = 1; i <= count; i++) {
      await this.createPost(
        page,
        `Test Post ${i}`,
        `This is test post number ${i} created for performance testing. It contains enough content to simulate a real blog post.`,
        i % 3 !== 0, // Make every 3rd post a draft
      );

      if (i % 10 === 0) {
        console.log(`Created ${i}/${count} posts`);
      }
    }

    console.log(`Finished creating ${count} test posts`);
  }

  /**
   * Waits for a specific number of posts to be visible on the index page
   * @param page - Playwright page object
   * @param expectedCount - Expected number of posts
   * @param timeout - Maximum time to wait in milliseconds
   */
  static async waitForPostCount(
    page: Page,
    expectedCount: number,
    timeout: number = 10000,
  ): Promise<void> {
    await page.goto("/posts");

    await page.waitForFunction(
      (count) => {
        const rows = document.querySelectorAll("tr");
        return rows.length - 1 === count; // Subtract header row
      },
      expectedCount,
      { timeout },
    );
  }
}
