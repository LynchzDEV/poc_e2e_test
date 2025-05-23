// Import the Playwright test runner
import { test as playwrightTest } from "@playwright/test";

// Re-export the test function to make it available for Bun
export const test = playwrightTest;

// Run the tests using the Playwright runner
import "./tests/posts.spec.ts";
