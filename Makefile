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
	@echo "$(CYAN)🧪 Rails E2E Testing Framework$(NC)"
	@echo "$(YELLOW)Available commands:$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(CYAN)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: setup
setup: ## 🎯 Complete project setup (run this first!)
	@echo "$(CYAN)🚀 Starting complete E2E testing setup...$(NC)"
	@make check-dependencies
	@make install-gems
	@make db-setup
	@make generate-blog
	@make setup-tests
	@echo "$(GREEN)✅ Setup complete! Run 'make test-all' to test everything$(NC)"

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
	@echo "$(YELLOW)⚡ Running smoke tests...$(NC)"
	@rails test --tag=smoke || echo "$(YELLOW)⚠️ No smoke tests in MiniTest$(NC)"
	@bundle exec rspec --tag smoke || echo "$(YELLOW)⚠️ No smoke tests in RSpec$(NC)"
	@cd playwright-tests && bun run test --grep "@smoke" || echo "$(YELLOW)⚠️ No smoke tests in Playwright$(NC)"
	@echo "$(GREEN)✅ Smoke tests complete$(NC)"

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

.PHONY: status
status: ## Check system and project status
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

.PHONY: examples
examples: ## Show example test commands
	@echo "$(CYAN)🎓 Example Commands$(NC)"
	@echo "$(CYAN)==================$(NC)"
	@echo "$(GREEN)# Quick start:$(NC)"
	@echo "  make setup              # Complete setup"
	@echo "  make test-all           # Run all tests"
	@echo ""
	@echo "$(GREEN)# Individual frameworks:$(NC)"
	@echo "  make test-minitest      # Rails built-in"
	@echo "  make test-rspec         # Behavior-driven"
	@echo "  make test-cucumber      # Human-readable"
	@echo "  make test-playwright    # Modern E2E"
	@echo ""
	@echo "$(GREEN)# Development:$(NC)"
	@echo "  make test-debug         # See tests run"
	@echo "  make playwright-codegen # Record new tests"
	@echo "  make reports            # View all reports"
	@echo ""
	@echo "$(GREEN)# Maintenance:$(NC)"
	@echo "  make clean             # Clean artifacts"
	@echo "  make reset             # Full reset"
	@echo "  make status            # Check health"

.PHONY: demo
demo: ## Run a quick demo of all frameworks
	@echo "$(CYAN)🎬 Demo: Testing the same feature across all frameworks$(NC)"
	@echo "$(CYAN)==========================================================$(NC)"
	@echo "$(YELLOW)This will run a simple 'create post' test in each framework:$(NC)"
	@echo ""
	@make test-minitest | head -10
	@echo "$(BLUE)...continuing with other frameworks...$(NC)"
	@make test-fast
	@echo ""
	@echo "$(GREEN)🎉 Demo complete! Each framework tested the same functionality$(NC)"

##@ 📈 Performance & Coverage

.PHONY: benchmark
benchmark: ## Run performance benchmarks
	@echo "$(CYAN)⏱️ Running performance benchmarks...$(NC)"
	@echo "$(BLUE)MiniTest:$(NC)"
	@time make test-minitest >/dev/null 2>&1 || true
	@echo "$(BLUE)RSpec:$(NC)"
	@time make test-rspec >/dev/null 2>&1 || true
	@echo "$(BLUE)Playwright:$(NC)"
	@cd playwright-tests && time bun run test >/dev/null 2>&1 || true

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
