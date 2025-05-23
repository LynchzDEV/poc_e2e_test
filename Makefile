# 🧪 Rails E2E Testing Framework Makefile
# Complete automation for MiniTest, RSpec, Capybara, Cucumber & Playwright

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
MAGENTA = \033[0;35m
CYAN = \033[0;36m
NC = \033[0m # No Color

# Project settings
PROJECT_NAME = e2e_test_poc
RAILS_ENV = test
DATABASE_NAME = $(PROJECT_NAME)_test
RAILS_PORT = 3000
PLAYWRIGHT_PORT = 3001

# Default target
.DEFAULT_GOAL := help

##@ 🚀 Setup Commands

.PHONY: help
help: ## Display this help message
	@echo "$(CYAN)🧪 Rails E2E Testing Framework - 5 Frameworks Showcase$(NC)"
	@echo "$(YELLOW)MiniTest • RSpec • Capybara • Cucumber • Playwright$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[0;32m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[0;36m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: setup
setup: ## 🎯 Complete project setup (run this first!)
	@echo "$(CYAN)🚀 Starting complete E2E testing setup...$(NC)"
	@make check-dependencies
	@make install-gems
	@make db-setup
	@make generate-blog
	@make setup-tests
	@echo "$(CYAN)🔍 Verifying all frameworks...$(NC)"
	@make verify-frameworks
	@echo "$(GREEN)✅ Setup complete! All 5 testing frameworks ready$(NC)"
	@echo "$(YELLOW)💡 Try: make test-all (run all tests) or make frameworks (see overview)$(NC)"

.PHONY: check-dependencies
check-dependencies: ## Check required system dependencies
	@echo "$(BLUE)🔍 Checking system dependencies...$(NC)"
	@command -v ruby >/dev/null 2>&1 || { echo "$(RED)❌ Ruby not found. Install Ruby 3.1+$(NC)"; exit 1; }
	@command -v rails >/dev/null 2>&1 || { echo "$(RED)❌ Rails not found. Run 'gem install rails'$(NC)"; exit 1; }
	@command -v psql >/dev/null 2>&1 || { echo "$(RED)❌ PostgreSQL not found. Install PostgreSQL$(NC)"; exit 1; }
	@command -v node >/dev/null 2>&1 || { echo "$(RED)❌ Node.js not found. Install Node.js 18+$(NC)"; exit 1; }
	@command -v bun >/dev/null 2>&1 || { echo "$(RED)❌ Bun not found. Install with: curl -fsSL https://bun.sh/install | bash$(NC)"; exit 1; }
	@echo "$(GREEN)✅ All dependencies found$(NC)"

.PHONY: install-gems
install-gems: ## Install Ruby gems
	@echo "$(BLUE)💎 Installing Ruby gems...$(NC)"
	@bundle install
	@echo "$(GREEN)✅ Gems installed$(NC)"

##@ 🗄️ Database Commands

.PHONY: db-setup
db-setup: ## Setup test database
	@echo "$(BLUE)🗄️ Setting up database...$(NC)"
	@RAILS_ENV=test rails db:drop db:create db:migrate
	@echo "$(GREEN)✅ Database ready$(NC)"

.PHONY: db-reset
db-reset: ## Reset test database
	@echo "$(BLUE)🔄 Resetting database...$(NC)"
	@RAILS_ENV=test rails db:reset
	@echo "$(GREEN)✅ Database reset$(NC)"

.PHONY: db-seed
db-seed: ## Seed test database with sample data
	@echo "$(BLUE)🌱 Seeding database...$(NC)"
	@RAILS_ENV=test rails db:seed
	@echo "$(GREEN)✅ Database seeded$(NC)"

##@ 🏗️ Application Setup

.PHONY: generate-blog
generate-blog: ## Generate sample blog application
	@echo "$(BLUE)📝 Generating blog scaffold...$(NC)"
	@rails generate scaffold Post title:string content:text published:boolean --skip-routes || true
	@RAILS_ENV=test rails db:migrate
	@echo "$(GREEN)✅ Blog scaffold generated$(NC)"

##@ 🧪 Testing Framework Setup

.PHONY: setup-tests
setup-tests: ## Setup all testing frameworks
	@echo "$(CYAN)🧪 Setting up all testing frameworks...$(NC)"
	@make setup-rspec
	@make setup-cucumber
	@make setup-playwright
	@echo "$(GREEN)✅ All testing frameworks ready$(NC)"

.PHONY: setup-rspec
setup-rspec: ## Setup RSpec testing framework
	@echo "$(BLUE)🔵 Setting up RSpec...$(NC)"
	@rails generate rspec:install --force || true
	@mkdir -p spec/factories spec/features
	@echo "$(GREEN)✅ RSpec ready$(NC)"

.PHONY: setup-cucumber
setup-cucumber: ## Setup Cucumber testing framework
	@echo "$(BLUE)🥒 Setting up Cucumber...$(NC)"
	@rails generate cucumber:install --force || true
	@mkdir -p features/step_definitions features/support
	@echo "$(GREEN)✅ Cucumber ready$(NC)"

.PHONY: setup-playwright
setup-playwright: ## Setup Playwright testing framework
	@echo "$(BLUE)🎭 Setting up Playwright...$(NC)"
	@if [ ! -d "playwright-tests" ]; then \
		bun create playwright@latest playwright-tests --yes; \
	fi
	@cd playwright-tests && bun install
	@cd playwright-tests && bun run install-browsers
	@mkdir -p playwright-tests/tests/helpers
	@echo "$(GREEN)✅ Playwright ready$(NC)"

##@ 🏃‍♂️ Individual Test Frameworks

.PHONY: test-minitest
test-minitest: ## Run MiniTest suite
	@echo "$(RED)🔴 Running MiniTest...$(NC)"
	@rails test
	@echo "$(GREEN)✅ MiniTest complete$(NC)"

.PHONY: test-rspec
test-rspec: ## Run RSpec suite
	@echo "$(BLUE)🔵 Running RSpec...$(NC)"
	@bundle exec rspec --format documentation
	@echo "$(GREEN)✅ RSpec complete$(NC)"

.PHONY: test-cucumber
test-cucumber: ## Run Cucumber scenarios
	@echo "$(YELLOW)🥒 Running Cucumber...$(NC)"
	@bundle exec cucumber --format pretty
	@echo "$(GREEN)✅ Cucumber complete$(NC)"

.PHONY: test-capybara
test-capybara: ## Run Capybara system tests
	@echo "$(CYAN)🐹 Running Capybara system tests...$(NC)"
	@rails test:system
	@echo "$(GREEN)✅ Capybara tests complete$(NC)"

.PHONY: test-playwright
test-playwright: ## Run Playwright E2E tests
	@echo "$(MAGENTA)🎭 Running Playwright...$(NC)"
	@cd playwright-tests && bun run test
	@echo "$(GREEN)✅ Playwright complete$(NC)"

##@ 🎯 Combined Test Commands

.PHONY: test-all
test-all: ## Run all testing frameworks sequentially
	@echo "$(CYAN)🧪 Running ALL testing frameworks...$(NC)"
	@echo "$(CYAN)================================================$(NC)"
	@make kill-server || true
	@make test-minitest || echo "$(RED)❌ MiniTest failed$(NC)"
	@make test-rspec || echo "$(RED)❌ RSpec failed$(NC)"
	@make test-cucumber || echo "$(RED)❌ Cucumber failed$(NC)"
	@make test-capybara || echo "$(RED)❌ Capybara failed$(NC)"
	@make test-playwright || echo "$(RED)❌ Playwright failed$(NC)"
	@echo "$(CYAN)================================================$(NC)"
	@echo "$(GREEN)🎉 All tests complete! Check reports with 'make reports'$(NC)"

.PHONY: test-parallel
test-parallel: ## Run all frameworks in parallel (experimental)
	@echo "$(CYAN)⚡ Running tests in parallel...$(NC)"
	@make test-minitest & \
	make test-rspec & \
	make test-cucumber & \
	wait
	@make test-playwright
	@echo "$(GREEN)✅ Parallel tests complete$(NC)"

.PHONY: test-fast
test-fast: ## Run quick smoke tests only
	@echo "$(YELLOW)⚡ Running smoke tests across all frameworks...$(NC)"
	@echo "$(RED)🔴 MiniTest smoke tests:$(NC)"
	@rails test --tag=smoke || echo "$(YELLOW)⚠️ No smoke tests tagged in MiniTest$(NC)"
	@echo "$(BLUE)🔵 RSpec smoke tests:$(NC)"
	@bundle exec rspec --tag smoke || echo "$(YELLOW)⚠️ No smoke tests tagged in RSpec$(NC)"
	@echo "$(CYAN)🐹 Capybara smoke tests:$(NC)"
	@rails test:system --tag=smoke || echo "$(YELLOW)⚠️ No smoke tests tagged in Capybara$(NC)"
	@echo "$(YELLOW)🥒 Cucumber smoke tests:$(NC)"
	@bundle exec cucumber --tags @smoke || echo "$(YELLOW)⚠️ No @smoke tagged scenarios in Cucumber$(NC)"
	@echo "$(MAGENTA)🎭 Playwright smoke tests:$(NC)"
	@cd playwright-tests && bun run test --grep "@smoke" || echo "$(YELLOW)⚠️ No @smoke tests in Playwright$(NC)"
	@echo "$(GREEN)✅ All smoke tests complete$(NC)"

.PHONY: test-debug
test-debug: ## Run Playwright tests with browser visible
	@echo "$(MAGENTA)🎭 Running Playwright in debug mode...$(NC)"
	@cd playwright-tests && bun run test:headed

##@ 📊 Reports & Documentation

.PHONY: reports
reports: ## Open all test reports
	@echo "$(CYAN)📊 Opening test reports...$(NC)"
	@make report-rspec
	@make report-cucumber
	@make report-playwright

.PHONY: report-rspec
report-rspec: ## Open RSpec HTML report
	@if [ -f "tmp/rspec_results.html" ]; then \
		open tmp/rspec_results.html || xdg-open tmp/rspec_results.html; \
	else \
		echo "$(YELLOW)⚠️ RSpec report not found. Run 'make test-rspec' first$(NC)"; \
	fi

.PHONY: report-cucumber
report-cucumber: ## Open Cucumber HTML report
	@if [ -f "tmp/cucumber_report.html" ]; then \
		open tmp/cucumber_report.html || xdg-open tmp/cucumber_report.html; \
	else \
		echo "$(YELLOW)⚠️ Cucumber report not found. Run 'make test-cucumber' first$(NC)"; \
	fi

.PHONY: report-playwright
report-playwright: ## Open Playwright HTML report
	@cd playwright-tests && bun run report

##@ 🔧 Development Commands

.PHONY: dev
dev: ## Start Rails development server
	@echo "$(GREEN)🚀 Starting Rails development server on port $(RAILS_PORT)...$(NC)"
	@rails server -p $(RAILS_PORT)

.PHONY: dev-test
dev-test: ## Start Rails test server
	@echo "$(GREEN)🧪 Starting Rails test server on port $(RAILS_PORT)...$(NC)"
	@RAILS_ENV=test rails server -p $(RAILS_PORT)

.PHONY: console
console: ## Open Rails console
	@rails console

.PHONY: console-test
console-test: ## Open Rails test console
	@RAILS_ENV=test rails console

.PHONY: routes
routes: ## Show all Rails routes
	@rails routes

##@ 🎮 Playwright Specific Commands

.PHONY: playwright-codegen
playwright-codegen: ## Generate Playwright tests by recording actions
	@echo "$(MAGENTA)🎭 Starting Playwright code generator...$(NC)"
	@cd playwright-tests && bun run codegen

.PHONY: playwright-ui
playwright-ui: ## Open Playwright UI mode
	@echo "$(MAGENTA)🎭 Opening Playwright UI...$(NC)"
	@cd playwright-tests && bun run test:ui

.PHONY: playwright-trace
playwright-trace: ## Run Playwright with trace recording
	@echo "$(MAGENTA)🎭 Running Playwright with trace...$(NC)"
	@cd playwright-tests && bun run test:trace

##@ 🧹 Cleanup Commands

.PHONY: clean
clean: ## Clean all test artifacts
	@echo "$(YELLOW)🧹 Cleaning test artifacts...$(NC)"
	@rm -rf tmp/screenshots tmp/capybara tmp/*.html
	@rm -rf playwright-tests/test-results playwright-tests/playwright-report
	@rm -rf playwright-tests/screenshots playwright-tests/videos
	@rm -rf coverage/
	@echo "$(GREEN)✅ Cleanup complete$(NC)"

.PHONY: clean-all
clean-all: clean ## Clean everything including node_modules
	@echo "$(YELLOW)🧹 Deep cleaning...$(NC)"
	@rm -rf playwright-tests/node_modules
	@rm -rf node_modules
	@echo "$(GREEN)✅ Deep cleanup complete$(NC)"

.PHONY: reset
reset: ## Reset everything (database, clean, setup)
	@echo "$(YELLOW)🔄 Resetting entire project...$(NC)"
	@make kill-server
	@make clean
	@make db-reset
	@make setup-tests
	@echo "$(GREEN)✅ Project reset complete$(NC)"

##@ 🔍 Status & Debug Commands

.PHONY: verify-frameworks
verify-frameworks: ## Verify all 5 testing frameworks are working
	@echo "$(CYAN)🔍 Verifying all 5 testing frameworks...$(NC)"
	@echo "$(CYAN)=========================================$(NC)"
	@echo "$(RED)🔴 Checking MiniTest...$(NC)"
	@rails test --help >/dev/null 2>&1 && echo "$(GREEN)✅ MiniTest ready$(NC)" || echo "$(RED)❌ MiniTest failed$(NC)"
	@echo "$(BLUE)🔵 Checking RSpec...$(NC)"
	@bundle exec rspec --version >/dev/null 2>&1 && echo "$(GREEN)✅ RSpec ready$(NC)" || echo "$(RED)❌ RSpec failed$(NC)"
	@echo "$(CYAN)🐹 Checking Capybara...$(NC)"
	@bundle exec ruby -r capybara -e "puts 'Capybara loaded'" >/dev/null 2>&1 && echo "$(GREEN)✅ Capybara ready$(NC)" || echo "$(RED)❌ Capybara failed$(NC)"
	@echo "$(YELLOW)🥒 Checking Cucumber...$(NC)"
	@bundle exec cucumber --version >/dev/null 2>&1 && echo "$(GREEN)✅ Cucumber ready$(NC)" || echo "$(RED)❌ Cucumber failed$(NC)"
	@echo "$(MAGENTA)🎭 Checking Playwright...$(NC)"
	@cd playwright-tests && bun run test --help >/dev/null 2>&1 && echo "$(GREEN)✅ Playwright ready$(NC)" || echo "$(RED)❌ Playwright failed$(NC)"
	@echo ""
	@echo "$(GREEN)🎉 Framework verification complete!$(NC)"
	@echo "$(CYAN)📊 System Status$(NC)"
	@echo "$(CYAN)===============$(NC)"
	@echo "$(BLUE)Ruby version:$(NC) $$(ruby --version)"
	@echo "$(BLUE)Rails version:$(NC) $$(rails --version)"
	@echo "$(BLUE)Node version:$(NC) $$(node --version)"
	@echo "$(BLUE)Bun version:$(NC) $$(bun --version)"
	@echo "$(BLUE)PostgreSQL:$(NC) $$(pg_config --version 2>/dev/null || echo 'Not found')"
	@echo ""
	@echo "$(CYAN)Project Status$(NC)"
	@echo "$(CYAN)===============$(NC)"
	@echo "$(BLUE)Database:$(NC) $$(RAILS_ENV=test rails runner 'puts ActiveRecord::Base.connection.current_database' 2>/dev/null || echo 'Not connected')"
	@echo "$(BLUE)Port 3000:$(NC) $$(lsof -i :3000 >/dev/null 2>&1 && echo 'In use' || echo 'Available')"
	@echo "$(BLUE)RSpec:$(NC) $$(test -f spec/rails_helper.rb && echo 'Configured' || echo 'Not setup')"
	@echo "$(BLUE)Cucumber:$(NC) $$(test -f features/support/env.rb && echo 'Configured' || echo 'Not setup')"
	@echo "$(BLUE)Playwright:$(NC) $$(test -d playwright-tests && echo 'Configured' || echo 'Not setup')"

.PHONY: logs
logs: ## Show recent test logs
	@echo "$(CYAN)📜 Recent test logs:$(NC)"
	@tail -n 50 log/test.log 2>/dev/null || echo "No test logs found"

.PHONY: kill-server
kill-server: ## Kill any running Rails servers
	@echo "$(YELLOW)🛑 Killing Rails servers...$(NC)"
	@pkill -f "rails server" || true
	@pkill -f "puma" || true
	@echo "$(GREEN)✅ Servers stopped$(NC)"

.PHONY: ports
ports: ## Show what's running on relevant ports
	@echo "$(CYAN)🔌 Port usage:$(NC)"
	@echo "$(BLUE)Port 3000:$(NC) $$(lsof -i :3000 2>/dev/null || echo 'Available')"
	@echo "$(BLUE)Port 3001:$(NC) $$(lsof -i :3001 2>/dev/null || echo 'Available')"

##@ 🎓 Learning & Examples

.PHONY: frameworks
frameworks: ## Show all 5 testing frameworks overview
	@echo "$(CYAN)🧪 All 5 Testing Frameworks Overview$(NC)"
	@echo "$(CYAN)====================================$(NC)"
	@echo "$(RED)🔴 MiniTest$(NC)     - Rails built-in, fast, simple assertions"
	@echo "$(BLUE)🔵 RSpec$(NC)        - Behavior-driven, readable syntax, rich matchers"
	@echo "$(CYAN)🐹 Capybara$(NC)     - Browser automation, user interaction simulation"
	@echo "$(YELLOW)🥒 Cucumber$(NC)     - Human-readable scenarios, stakeholder friendly"
	@echo "$(MAGENTA)🎭 Playwright$(NC)   - Modern E2E, cross-browser, TypeScript"
	@echo ""
	@echo "$(GREEN)Commands:$(NC)"
	@echo "  make test-minitest    # Run Rails built-in tests"
	@echo "  make test-rspec       # Run RSpec behavior tests"
	@echo "  make test-capybara    # Run browser simulation tests"
	@echo "  make test-cucumber    # Run human-readable scenarios"
	@echo "  make test-playwright  # Run modern E2E tests"
	@echo "  make test-all         # Run ALL frameworks"
	@echo "  make benchmark        # Compare performance"

.PHONY: examples
examples: ## Show example test commands
	@echo "$(CYAN)🎓 Example Commands - All 5 Testing Frameworks$(NC)"
	@echo "$(CYAN)===============================================$(NC)"
	@echo "$(GREEN)# Quick start:$(NC)"
	@echo "  make setup              # Complete setup"
	@echo "  make test-all           # Run all 5 frameworks"
	@echo ""
	@echo "$(GREEN)# Individual frameworks:$(NC)"
	@echo "  make test-minitest      # 🔴 Rails built-in (fast)"
	@echo "  make test-rspec         # 🔵 Behavior-driven (readable)"
	@echo "  make test-capybara      # 🐹 Browser simulation (user-like)"
	@echo "  make test-cucumber      # 🥒 Human-readable scenarios"
	@echo "  make test-playwright    # 🎭 Modern E2E (cross-browser)"
	@echo ""
	@echo "$(GREEN)# Performance comparison:$(NC)"
	@echo "  make benchmark          # Compare speed of all 5 frameworks"
	@echo "  make test-fast          # Quick smoke tests across all"
	@echo ""
	@echo "$(GREEN)# Development:$(NC)"
	@echo "  make test-debug         # See Playwright tests run"
	@echo "  make playwright-codegen # Record new tests"
	@echo "  make reports            # View all reports"
	@echo ""
	@echo "$(GREEN)# Maintenance:$(NC)"
	@echo "  make clean             # Clean artifacts"
	@echo "  make reset             # Full reset"
	@echo "  make status            # Check health"

.PHONY: demo
demo: ## Run a quick demo of all frameworks
	@echo "$(CYAN)🎬 Demo: Testing the same feature across all 5 frameworks$(NC)"
	@echo "$(CYAN)============================================================$(NC)"
	@echo "$(YELLOW)This will run a simple 'create post' test in each framework:$(NC)"
	@echo ""
	@echo "$(RED)🔴 MiniTest (Rails built-in - fast, simple):$(NC)"
	@make test-minitest | head -10
	@echo ""
	@echo "$(BLUE)🔵 RSpec (Behavior-driven - readable):$(NC)"
	@make test-rspec | head -10
	@echo ""
	@echo "$(CYAN)🐹 Capybara (Browser simulation):$(NC)"
	@make test-capybara | head -10
	@echo ""
	@echo "$(YELLOW)🥒 Cucumber (Human-readable scenarios):$(NC)"
	@make test-cucumber | head -10
	@echo ""
	@echo "$(MAGENTA)🎭 Playwright (Modern E2E - cross-browser):$(NC)"
	@make test-playwright | head -10
	@echo ""
	@echo "$(GREEN)🎉 Demo complete! Each framework tested the same functionality$(NC)"
	@echo "$(CYAN)💡 Notice how each framework has different syntax but tests the same features$(NC)"

##@ 📈 Performance & Coverage

.PHONY: benchmark
benchmark: ## Run performance benchmarks for all frameworks
	@echo "$(CYAN)⏱️ Running performance benchmarks...$(NC)"
	@echo "$(CYAN)Comparing all 5 testing frameworks:$(NC)"
	@echo ""
	@echo "$(RED)🔴 MiniTest (Rails built-in):$(NC)"
	@time make test-minitest >/dev/null 2>&1 || true
	@echo ""
	@echo "$(BLUE)🔵 RSpec (Behavior-driven):$(NC)"
	@time make test-rspec >/dev/null 2>&1 || true
	@echo ""
	@echo "$(CYAN)🐹 Capybara (System tests):$(NC)"
	@time make test-capybara >/dev/null 2>&1 || true
	@echo ""
	@echo "$(YELLOW)🥒 Cucumber (BDD scenarios):$(NC)"
	@time make test-cucumber >/dev/null 2>&1 || true
	@echo ""
	@echo "$(MAGENTA)🎭 Playwright (E2E TypeScript):$(NC)"
	@cd playwright-tests && time bun run test >/dev/null 2>&1 || true
	@echo ""
	@echo "$(GREEN)✅ Benchmark complete! All 5 frameworks tested$(NC)"

.PHONY: coverage
coverage: ## Generate test coverage report
	@echo "$(CYAN)📊 Generating coverage report...$(NC)"
	@COVERAGE=true bundle exec rspec
	@echo "$(GREEN)✅ Coverage report generated in coverage/$(NC)"

##@ 🚀 CI/CD Helpers

.PHONY: ci-setup
ci-setup: ## Setup for CI environment
	@echo "$(CYAN)🤖 CI Setup$(NC)"
	@make check-dependencies
	@make install-gems
	@make db-setup
	@make setup-tests

.PHONY: ci-test
ci-test: ## Run tests in CI mode
	@echo "$(CYAN)🤖 Running CI tests$(NC)"
	@RAILS_ENV=test make test-all

.PHONY: docker-test
docker-test: ## Run tests in Docker (if Dockerfile exists)
	@if [ -f "Dockerfile" ]; then \
		docker build -t $(PROJECT_NAME)-test . && \
		docker run --rm $(PROJECT_NAME)-test make ci-test; \
	else \
		echo "$(YELLOW)⚠️ Dockerfile not found$(NC)"; \
	fi

# Prevent make from interpreting files as targets
.PHONY: all clean install test
